import 'package:adobe_app/managers/class_manager.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({
    super.key,
    required this.classId,
    required this.className,
  });

  final String classId;
  final String className;

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyTitle(text: widget.className),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          FutureBuilder(
            future: ClassManager.instance.getClassInfo(widget.classId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              return TextButton(
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (context) {
                      // ignore: prefer_interpolation_to_compose_strings
                      return AlertDialog(
                        title: MyTitle(
                          text: "Join Code: ${snapshot.data!['join_code']}",
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Done"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: MyTitle(text: snapshot.data!['join_code'], fontSize: 15),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: ClassManager.instance.getClassInfo(widget.classId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final studentIDS = snapshot.data?['students'];
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 45),
                  MyTitle(text: "Current Learning Idea:", fontSize: 18),
                  SizedBox(height: 20),

                  // LEARNING GOAL TEXTBOX
                  SizedBox(
                    width: 500,
                    child: MyTextField(controller: controller)
                  ),

                  SizedBox(height: 20),

                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        child: Text("Save"),
                      ),
                    ),
                    onTap: () async {
                      await ClassManager.instance.updateLearningTarget(widget.classId, controller.text);
                    },
                  ),

                  SizedBox(height: 45),
                  MyTitle(text: "Students:", fontSize: 18),

                  ...studentIDS.map((studentID) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: 1000,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: FutureBuilder(
                            future: ClassManager.instance.getUserInfo(
                              studentID,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              return MyTitle(text: snapshot.data?['email']);
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
