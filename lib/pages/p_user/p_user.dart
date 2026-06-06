import 'package:adobe_app/managers/auth_manager.dart';
import 'package:adobe_app/managers/class_manager.dart';
import 'package:adobe_app/pages/p_user/p_classroom.dart';
import 'package:adobe_app/pages/p_user/p_teacher_dash.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';

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
                final names = await ClassManager.instance.getMyClassNames();
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

  Future<void> showJoinClassDialogue() async {
    final code = TextEditingController();

    return showDialog<void>(
      context: (context),
      builder: (BuildContext context) {
        return AlertDialog(
          title: MyTitle(text: "Join Class"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {
                final error = await ClassManager.instance.joinClass(code.text);

                if (error != null) {
                  SnackBar snackBar = SnackBar(content: Text(error));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                Navigator.pop(context);
              },
              child: Text("Join Class"),
            ),
          ],
          content: SizedBox(
            width: 200,
            child: MyTextField(controller: code, hintText: "Code"),
          ),
        );
      },
    );
  }

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
            MyTitle(text: "My Classes: ", fontSize: 21),
            SizedBox(height: 15,),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: FutureBuilder<List<String>>(
                future: ClassManager.instance.getMyClassNames(),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => TeacherDashboardPage(
                                      classId: className,
                                      className: className.replaceAll(
                                        AuthManager.instance.currentUser()!.id,
                                        "",
                                      ),
                                    ),
                                  ),
                                );
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


            SizedBox(height: 50,),

            MyTitle(text: "Join Classes: ", fontSize: 21),
            SizedBox(height: 15,),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: FutureBuilder<List<String>>(
                future: ClassManager.instance.getJoinedClassNames(),
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
                            await showJoinClassDialogue();
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
                          (className) => FutureBuilder(
                            future: ClassManager.instance.getClassInfo(
                              className,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }


                              final data = snapshot.data;
                              return Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClassroomPage(
                                          classId: className,
                                          className: className.replaceAll(
                                            data?['owner_id'],
                                            "",
                                          ),
                                        ),
                                      ),
                                    );
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
                                          data?['owner_id'],
                                          "",
                                        ),

                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
