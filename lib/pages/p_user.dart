import 'package:adobe_app/auth_manager.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              AuthManager.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
