import 'package:adobe_app/class_manager.dart';
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
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text("Done"))
                        ],
                      );
                    },
                  );
                },
                child: MyTitle(text: snapshot.data!['join_code']),
              );
            },
          ),
        ],
      ),
    );
  }
}
