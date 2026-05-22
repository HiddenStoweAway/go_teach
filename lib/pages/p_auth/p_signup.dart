import 'package:adobe_app/auth_manager.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfController = TextEditingController();

  void signUp(BuildContext context) async {
    if (passwordConfController.text.isEmpty ||
        passwordController.text.isEmpty ||
        emailController.text.isEmpty) {
      SnackBar snackBar = SnackBar(
        content: Text("One or more fields are empty"),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (passwordConfController.text != passwordController.text) {
      SnackBar snackBar = SnackBar(content: Text("Passwords do not match"));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try {
      AuthManager auth = AuthManager.instance;
      await auth.signUp(emailController.text, passwordController.text);

      Navigator.pop(context);
    } on AuthException catch (e) {
      SnackBar snackBar = SnackBar(content: Text(e.message));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyTitle(text: "Sign Up!"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyTitle(
                    text: "Enter your registration information: ",
                    fontSize: 18,
                  ),

                  SizedBox(height: 75),

                  // EMAIL CONTROLLER
                  MyTextField(controller: emailController, hintText: "Email"),

                  SizedBox(height: 45),

                  // PASSWORD
                  MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    hideText: true,
                  ),

                  SizedBox(height: 45),

                  // CONF PASSWORD
                  MyTextField(
                    controller: passwordConfController,
                    hintText: "Confirm Password",
                    hideText: true,
                  ),

                  SizedBox(height: 35),

                  // SUBMIT BUTTON
                  GestureDetector(
                    onTap: () {
                      signUp(context);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: MyTitle(
                          text: "Sign Up!",
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
