import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: MyTitle(text: widget.className),
      ),
    );
  }
}