import 'package:adobe_app/managers/chat_manager.dart';
import 'package:adobe_app/managers/class_manager.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassroomPage extends StatefulWidget {
  const ClassroomPage({
    super.key,
    required this.classId,
    required this.className,
  });

  final String classId;
  final String className;

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  ChatManager? _chatManager;
  bool _loading = true;
  List<Map<String, String>> messages = [];
  final controller = TextEditingController();
  final scrollController = ScrollController();

  void sendMessage(String msg) async {
    setState(() {
      messages.add({'role': 'user', 'text': msg});
      messages.add({'text': 'Loading...'});
    });

    print("Hey");
    final response = await _chatManager?.sendMessage(widget.classId, msg);
    print("Y");

    setState(() {
      messages.removeLast();
      print(_chatManager);
      messages.add({'role': 'model', 'text': response!});
      controller.text = "";
    });
  }

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final target = await ClassManager.instance.getLearningTarget(
      widget.classId,
    );
    _chatManager = ChatManager(target);
    await _chatManager!.load(widget.classId);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final rows = await Supabase.instance.client
        .from('messages')
        .select()
        .eq('class_id', widget.classId)
        .eq('user_id', userId)
        .eq('current_learning_goal', target)
        .order('created_at', ascending: true);
    print(rows);

    setState(() {
      messages = rows
          .map<Map<String, String>>(
            (r) => {'role': r['role'], 'text': r['content']},
          )
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: MyTitle(text: widget.className),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ...messages.map((message) {
                        final isUser = message['role'] == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: MarkdownBody(
                              data: message['text']!,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                                ),
                                strong: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.multiline,
                          maxLines: null, // allows unlimited lines
                          decoration: InputDecoration(
                            hintText: 'Enter response...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => sendMessage(controller.text),
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
