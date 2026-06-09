import 'package:adobe_app/api_keys.dart';
import 'package:adobe_app/managers/auth_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatManager {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatManager(String learningGoal) {
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
        '- Always end your response with either a question or a prompt to keep me engaged.';

    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // cheapest, fast
      apiKey: ApiKeys.instance.gemini,
      systemInstruction: Content.system(
        systemInstruction
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
      await _saveMessage("model", response.text ?? "No Response", classID);
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
