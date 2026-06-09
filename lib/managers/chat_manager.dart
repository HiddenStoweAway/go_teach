import 'package:adobe_app/api_keys.dart';
import 'package:adobe_app/managers/auth_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatManager {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatManager(String learningGoal) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // cheapest, fast
      apiKey: ApiKeys.instance.gemini,
      systemInstruction: Content.system(
        'You are a patient teacher trying to teach me about $learningGoal. '
        'Your goal is to teach me this and diagnose and hold my progress. '
        'When you think I have adequately learned it, give me homework questions to grade. '
        'Make sure to stick to the correct topic, and ask me practice questions to access my knowledge'
        'IMPORTANT: Do not use LaTeX or dollar sign math notation. '
        'Write math variables and expressions in plain text instead, for example write x and y instead of \$x\$ and \$y\$.',
      ),
    );
  }

  Future<void> load(String classID) async {
    final history = await getHistory(classID);
    print("AB");

    try {
      _chat = _model.startChat(history: history);
    } catch (e) {
      print(e);
    } // this holds history automatically

    print('ABC');
    if (history.isEmpty) {
      final response = await _chat.sendMessage(Content.text("Hello"));
      _saveMessage("model", response.text ?? "No Response", classID);
      print("Send");
    }
  }

  Future<List<Content>> getHistory(String classId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final rows = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('class_id', classId)
          .eq('user_id', userId)
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

  Future<String> sendMessage(String classID, String message) async {
    try {
      await _saveMessage('user', message, classID);

      final response = await _chat.sendMessage(Content.text(message));

      final reply = response.text ?? 'No response';
      await _saveMessage('model', reply, classID);
      return reply;
    } catch (e, stackTrace) {
      print("XXX");
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
    });
  }
}
