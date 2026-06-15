import 'package:adobe_app/api_keys.dart';
import 'package:adobe_app/managers/auth_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatManager {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  late final String target;

  ChatManager(String learningGoal) {
    target = learningGoal;
    final systemInstruction =
        'You are an expert, patient tutor teaching me about $learningGoal. '
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
        'Important rules: '
        '- Only teach topics related to $learningGoal. Politely redirect me if I go off topic. '
        '- Never use LaTeX or dollar sign math notation. Write math expressions in plain text, for example write x squared instead of x^2. '
        '- Keep responses concise and conversational. Do not overwhelm me with too much information at once. '
        '- Always end your response with either a question or a prompt to keep me engaged.'
        'Only leave report fields as null if there is not yet enough data to assess.'
        'RESPONSE FORMAT: You must always respond in exactly this format and nothing else: '
        '<CONTENT>your message to the student here</CONTENT>'
        '<REPORT>understanding=high/medium/low|strengths=...|weaknesses=...|progress=...</REPORT>'
        'Leave report fields as "none" if there is not enough data yet.';

    _model = GenerativeModel(
      model: 'gemini-3.5-flash', // cheapest, fast
      apiKey: ApiKeys.instance.gemini,
      systemInstruction: Content.system(systemInstruction),
    );
  }

  Future<void> load(String classID) async {
    final history = await getHistory(classID);
    try {
      _chat = _model.startChat(history: history);
    } catch (e) {
      print(e);
    } // this holds history automatically

    if (history.isEmpty) {
      final response = await _chat.sendMessage(Content.text("Hello"));

      // strip markdown code fences if Gemini wraps in ```json
      final raw = response.text ?? '';
      final parsed = _parseResponse(raw);
      final content = parsed['content'] as String;

      await _saveMessage("model", content, classID);
      print("Send");
    }
  }

  Future<List<Content>> getHistory(String classId) async {
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

      final history = rows
          .map((row) => Content(row['role'], [TextPart(row['content'])]))
          .toList();

      return history;
    } on PostgrestException catch (e) {
      print(e.message);
    }

    return [];
  }

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
            return MapEntry(split[0].trim(), split.sublist(1).join('=').trim());
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

  Future<String> sendMessage(String classID, String message) async {
    try {
      await _saveMessage('user', message, classID);

      final response = await _chat.sendMessage(Content.text(message));
      // strip markdown code fences if Gemini wraps in ```json
      final raw = response.text ?? '';
      final parsed = _parseResponse(raw);
      final content = parsed['content'] as String;
      final report = parsed['report'] as Map<String, String>?;

      print(parsed);

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

  Future<void> _saveMessage(String role, String content, String classId) async {
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
      onConflict:
          'class_id, student_id, current_learning_goal', // update existing row instead of inserting
    );
  }
}
