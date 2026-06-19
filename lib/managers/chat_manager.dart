import 'package:adobe_app/managers/auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatManager {
  late final String target;
  late final String _systemInstruction;
  final List<Map<String, dynamic>> _history = [];
  bool usingFallback = false;

  static const _primaryModel = 'gemini-2.5-flash';
  static const _fallbackModel = 'gemini-2.5-flash-lite';

  ChatManager(String learningGoal) {
    target = learningGoal;
    _systemInstruction =
        'You are an expert, patient tutor teaching me about the following learning goal: $learningGoal. '
        'Your primary goal is to identify my strengths and weaknesses and adapt your teaching style accordingly. '
        'Follow this teaching approach: '
        '1. Start by asking me a few diagnostic questions to assess my current knowledge level. '
        '2. Based on my answers, identify what I already understand and what I am struggling with. '
        '3. Focus your explanations on the areas I am weakest in, using analogies and simple examples. '
        '4. After each explanation, ask me a question to check my understanding before moving on. '
        '5. If I answer incorrectly, do not just give me the answer. Instead, guide me with hints and simpler sub-questions until I reach the correct answer myself. '
        '6. Keep track of topics I consistently struggle with and revisit them later. '
        '7. Adapt your language and complexity to match my demonstrated level of understanding. '
        'Progress tracking: '
        '- If I answer correctly and confidently, increase the difficulty slightly. '
        '- If I answer incorrectly or seem confused, slow down and break the concept into smaller pieces. '
        '- Only move on to a new subtopic when I have demonstrated clear understanding of the current one. '
        'When you are confident I have mastered $learningGoal, present me with a final set of homework questions that cover all the key concepts. Grade my answers and give detailed feedback. '
        'After this, if you are satisfied I have learned the content, you may politely end the conversation. '
        'Important rules: '
        '- Only teach topics related to $learningGoal. Politely redirect me if I go off topic. '
        '- Never use LaTeX or dollar sign math notation. Write math expressions in plain text, for example write x squared instead of x^2. '
        '- Keep responses concise and conversational. Do not overwhelm me with too much information at once. '
        '- Always end your response with either a question or a prompt to keep me engaged. '
        'RESPONSE FORMAT: You must always respond in exactly this format and nothing else: '
        '<CONTENT>your message to the student here</CONTENT>'
        '<REPORT>understanding=high/medium/low|strengths=...|weaknesses=...|progress=...</REPORT>'
        'Make sure understanding is truly reflective of the understanding of specifically the learning goal. '
        'Leave report fields as "none" if there is not yet enough data to assess, but include a report when applicable and necessary.';
  }

  // ---------- LOAD / HISTORY ----------

  Future<void> load(String classID) async {
    final history = await getHistory(classID);
    _history.clear();
    _history.addAll(history);

    if (_history.isEmpty) {
      final raw = await _callEdgeFunction("Hello");
      final parsed = _parseResponse(raw);
      final content = parsed['content'] as String;

      _history.add({
        'role': 'model',
        'parts': [
          {'text': raw},
        ],
      });

      await _saveMessage("model", content, classID);
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String classId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      print(target);
      final rows = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('class_id', classId)
          .eq('user_id', userId)
          .eq('current_learning_goal', target)
          .order('created_at');

      if (rows.isEmpty) return [];

      return rows
          .map<Map<String, dynamic>>(
            (row) => {
              'role': row['role'],
              'parts': [
                {'text': row['content']},
              ],
            },
          )
          .toList();
    } on PostgrestException catch (e) {
      print(e.message);
    }

    return [];
  }

  // ---------- PARSING ----------

  Map<String, dynamic> _parseResponse(String raw) {
    try {
      final contentMatch = RegExp(
        r'<CONTENT>(.*?)<\/CONTENT>',
        dotAll: true,
      ).firstMatch(raw);
      final reportMatch = RegExp(
        r'<REPORT>(.*?)<\/REPORT>',
        dotAll: true,
      ).firstMatch(raw);

      final content = contentMatch?.group(1)?.trim() ?? raw;

      Map<String, String>? report;
      if (reportMatch != null) {
        final reportStr = reportMatch.group(1)!;
        final fields = Map.fromEntries(
          reportStr.split('|').map((part) {
            final split = part.split('=');
            return MapEntry(
              split[0].trim(),
              split.sublist(1).join('=').trim(),
            );
          }),
        );
        report = {
          'understanding': fields['understanding'] ?? 'none',
          'strengths': fields['strengths'] ?? 'none',
          'weaknesses': fields['weaknesses'] ?? 'none',
          'progress': fields['progress'] ?? 'none',
        };
      }

      return {'content': content, 'report': report};
    } catch (e) {
      print('Parse error: $e');
      return {'content': raw, 'report': null};
    }
  }

  // ---------- EDGE FUNCTION CALL (replaces direct Gemini SDK calls) ----------

  Future<String> _callEdgeFunction(String message) async {
    final model = usingFallback ? _fallbackModel : _primaryModel;

    for (int i = 0; i < 3; i++) {
      try {
        final response = await Supabase.instance.client.functions.invoke(
          'chat',
          body: {
            'systemInstruction': _systemInstruction,
            'history': _history,
            'message': message,
            'model': model,
          },
        );

        final data = response.data;

        if (data is Map && data['error'] != null) {
          final errStr = data['error'].toString();
          print('Edge function error: $errStr');

          if (errStr.contains('503') && i < 2) {
            await Future.delayed(Duration(seconds: (i + 1) * 2)); // 2s, 4s
            continue;
          }

          if (!usingFallback) {
            print("SWITCH to fallback model");
            usingFallback = true;
            return _callEdgeFunction(message); // retry once with fallback model
          }

          return 'both models failed to deliver a response: $errStr';
        }

        return data['text'] as String? ?? '';
      } catch (e) {
        print('Edge function call failed: $e');
        if (i == 2) {
          return 'error: could not reach the server';
        }
        await Future.delayed(Duration(seconds: (i + 1) * 2));
      }
    }

    return 'error';
  }

  // ---------- SEND MESSAGE ----------

  Future<String> sendMessage(String classID, String message) async {
    try {
      await _saveMessage('user', message, classID);
      _history.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      final raw = await _callEdgeFunction(message);
      final parsed = _parseResponse(raw);
      final content = parsed['content'] as String;
      final report = parsed['report'] as Map<String, String>?;

      print(parsed);

      _history.add({
        'role': 'model',
        'parts': [
          {'text': raw},
        ],
      });

      if (report != null) {
        await _saveReport(classID, report);
        print(report);
      }

      await _saveMessage('model', content, classID);
      return content;
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('STACK: $stackTrace');
      return 'error';
    }
  }

  // ---------- SUPABASE SAVES ----------

  Future<void> _saveMessage(
    String role,
    String content,
    String classId,
  ) async {
    final userId = AuthManager.instance.currentUser()!.id;
    await Supabase.instance.client.from('messages').insert({
      'class_id': classId,
      'user_id': userId,
      'role': role,
      'content': content,
      'current_learning_goal': target,
    });
  }

  Future<void> _saveReport(String classId, Map<String, String> report) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client.from('reports').upsert(
      {
        'class_id': classId,
        'student_id': userId,
        'current_learning_goal': target,
        'understanding': report['understanding'],
        'strengths': report['strengths'],
        'weaknesses': report['weaknesses'],
        'progress': report['progress'],
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'class_id, student_id, current_learning_goal',
    );
  }
}