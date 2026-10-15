import 'package:adobe_app/managers/class_manager.dart';
import 'package:adobe_app/managers/mynav.dart';
import 'package:adobe_app/pages/p_user/p_student_info.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key, required this.classId});

  final String classId;

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  final controller = TextEditingController();

  String getClassName(Map<String, dynamic> classInfo) {
    return classInfo['class_id'].replaceAll(classInfo['owner_id'], "");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ClassManager.instance.getClassInfo(widget.classId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final studentIDS = snapshot.data?['students'];
        return Scaffold(
          appBar: AppBar(
            title: MyTitle(text: getClassName(snapshot.data!)),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              TextButton(
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
              ),
            ],
            leading: IconButton(
              onPressed: () {
                Nav.go(context, '/');
              },
              icon: Image(
                image: AssetImage('assets/logo-500x500.png'),
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          body: SingleChildScrollView(
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

                        if (snapshot.data != null) {
                          controller.text = snapshot.data!;
                        }

                        return MyTextField(
                          controller: controller,
                          hintText: "Current Learning Idea",
                        );
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
                      if (controller.text.isEmpty) {
                        SnackBar snackBar = SnackBar(
                          content: Text("Cannot leave goal empty"),
                        );
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        return;
                      }

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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          // color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              MyTitle(text: "Understanding icons: "),
                              Text("Completed: "),
                              Icon(Icons.check, color: Colors.blue),

                              Text("High: "),
                              Icon(Icons.thumb_up, color: Colors.green),

                              Text("Medium: "),
                              Icon(Icons.access_time, color: Colors.orange),

                              Text("Low: "),
                              Icon(
                                Icons.assignment_late_rounded,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  ...studentIDS.map((studentID) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () async {
                          final reports = await ClassManager.instance
                              .getUserReports(studentID);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return StudentInfoPage(
                                  classID: widget.classId,
                                  studentID: studentID,
                                  reports: reports,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 1000,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
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
                                        ClassManager.instance.getUserReports(
                                          studentID,
                                        ),
                                        ClassManager.instance.getLearningTarget(
                                          widget.classId,
                                        ),
                                      ]),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }

                                        final reports =
                                            snapshot.data![0]
                                                as List<Map<String, dynamic>>;
                                        // final target =
                                        //     snapshot.data![1] as String;

                                        if (reports.isEmpty) {
                                          return Icon(Icons.question_mark);
                                        }

                                        return reports[0]['understanding'] ==
                                                'low'
                                            ? Icon(
                                                Icons.assignment_late_rounded,
                                                color: Colors.red,
                                              )
                                            : reports[0]['understanding'] ==
                                                  'medium'
                                            ? Icon(
                                                Icons.access_time,
                                                color: Colors.orange,
                                              )
                                            : reports[0]['understanding'] ==
                                                  'high'
                                            ? Icon(
                                                Icons.thumb_up,
                                                color: Colors.green,
                                              )
                                            : reports[0]['understanding'] ==
                                                  'complete'
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.blue,
                                              )
                                            : Icon(Icons.question_mark);
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
          ),
        );
      },
    );
  }
}
