import 'package:adobe_app/managers/class_manager.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';

class StudentInfoPage extends StatefulWidget {
  const StudentInfoPage(
      {super.key,
      required this.classID,
      required this.studentID,
      required this.reports});

  final String classID;
  final String studentID;
  final List<Map<String, dynamic>> reports;

  @override
  State<StudentInfoPage> createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudentInfoPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            Future.wait([ClassManager.instance.getUserInfo(widget.studentID)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final studentInfo = snapshot.data![0];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: MyTitle(text: "${studentInfo['email']} Progress"),
            ),
            body: Center(
              child: Column(
                children: [
                  ...widget.reports.map((report) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Container(
                        width: 1000,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color:
                                Theme.of(context).colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  report['understanding'] == 'low'
                                      ? Icon(Icons.assignment_late_rounded,
                                          color: Colors.red)
                                      : report['understanding'] == 'medium'
                                          ? Icon(Icons.access_time,
                                              color: Colors.orange)
                                          : report['understanding'] == 'high'
                                              ? Icon(Icons.check,
                                                  color: Colors.green)
                                              : Icon(Icons.question_mark),
                                  MyTitle(
                                      text: report['current_learning_goal']),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  MyTitle(text: "Strengths:"),
                                  Expanded(child: Text(report['strengths'], softWrap: true,)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  MyTitle(text: "Weaknesses:"),
                                  Expanded(child: Text(report['weaknesses'], softWrap: true)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  MyTitle(text: "Progress:"),
                                  Expanded(child: Text(report['progress'], softWrap: true,)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        });
  }
}
