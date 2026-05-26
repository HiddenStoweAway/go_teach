import 'package:adobe_app/auth_manager.dart';
import 'package:adobe_app/class_manager.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<void> showCreateClassDialogue() async {
    final className = TextEditingController();

    return showDialog<void>(
      context: (context),
      builder: (BuildContext context) {
        return AlertDialog(
          title: MyTitle(text: "Create Class"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {
                final names = await ClassManager.instance.getClassNames();
                if (names.contains(
                  AuthManager.instance.currentUser()!.id + className.text,
                )) {
                  SnackBar snackBar = SnackBar(
                    content: Text(
                      "Already have a class called: ${className.text}",
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  Navigator.pop(context);
                  return;
                }

                await ClassManager.instance.addClass(className.text);

                Navigator.pop(context);
              },
              child: Text("Add Class"),
            ),
          ],
          content: SizedBox(
            width: 200,
            child: MyTextField(controller: className, hintText: "Class name"),
          ),
        );
      },
    );
  }

  void joinClass() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyTitle(text: AuthManager.instance.currentUser()!.email!),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              AuthManager.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTitle(text: "Classes: ", fontSize: 21),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: FutureBuilder<List<String>>(
                future: ClassManager.instance.getClassNames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final classes = snapshot.data ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await showCreateClassDialogue();
                            setState(() {}); // refresh after adding
                          },
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(Icons.add_circle_outline, size: 25),
                          ),
                        ),
                        ...classes.map(
                          (className) => Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: GestureDetector(
                              onTap: () {
                                print(className);
                              },
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: MyTitle(
                                    text: className.replaceAll(
                                      AuthManager.instance.currentUser()!.id,
                                      "",
                                    ),

                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
