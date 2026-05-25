import 'package:adobe_app/auth_manager.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  void joinClass(){

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
            MyTitle(text:"Classes: ", fontSize: 21,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      joinClass();
                    },
                    child: Container(
                      width: 250,
                      height: 250,
              
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(15)
                      ),

                      child: Icon(Icons.add_circle_outline, size: 25,),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
