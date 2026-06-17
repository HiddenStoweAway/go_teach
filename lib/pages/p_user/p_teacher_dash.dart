import 'package:adobe_app/managers/class_manager.dart';
import 'package:adobe_app/pages/p_user/p_student_info.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: snapshot.data!['join_code'],
                                ),
                              );

                              final snackBar = SnackBar(
                                content: Text("Copied to Clipboard"),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(snackBar);
                            },
                            child: Text("Copy to Clipboard"),
                          ),
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
                    child: FutureBuilder(
                      future: ClassManager.instance.getLearningTarget(
                        widget.classId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        controller.text = snapshot.data!;

                        return MyTextField(controller: controller);
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: Text("Save"),
                      ),
                    ),
                    onTap: () async {
                      await ClassManager.instance.updateLearningTarget(
                        widget.classId,
                        controller.text,
                      );

                      SnackBar snackBar = SnackBar(content: Text("Saved"));

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),

                  SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyTitle(text: "Students:", fontSize: 18),
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.info_outline)),
                    ],
                  ),

                  ...studentIDS.map((studentID) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () async {
                          final reports = await ClassManager.instance
                              .getUserReports(studentID);

                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return StudentInfoPage(
                                classID: widget.classId,
                                studentID: studentID,
                                reports: reports);
                          }));
                        },
                        child: Container(
                          width: 1000,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
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

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyTitle(text: snapshot.data?['email']),
                                    FutureBuilder(
                                      future: Future.wait([
                                        ClassManager.instance
                                            .getUserReports(studentID),
                                        ClassManager.instance
                                            .getLearningTarget(widget.classId)
                                      ]),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }

                                        final reports = snapshot.data![0]
                                            as List<Map<String, dynamic>>;
                                        final target =
                                            snapshot.data![1] as String;

                                        if(reports.isEmpty){
                                          return Icon(Icons.question_mark);
                                        }

                                        if (reports[0]
                                                ['current_learning_goal'] ==
                                            target) {
                                          if (reports[0]['understanding'] ==
                                              'low') {
                                            return Icon(
                                                Icons.assignment_late_rounded,
                                                color: Colors.red);
                                          } else if (reports[0]
                                                  ['understanding'] ==
                                              'medium') {
                                            return Icon(Icons.access_time,
                                                color: Colors.orange);
                                          } else if (reports[0]
                                                  ['understanding'] ==
                                              'high') {
                                            return Icon(Icons.check,
                                                color: Colors.green);
                                          }
                                        }
                                        return Icon(Icons.question_mark);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
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
