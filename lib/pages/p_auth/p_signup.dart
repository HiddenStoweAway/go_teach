import 'package:adobe_app/managers/auth_manager.dart';
import 'package:adobe_app/managers/mynav.dart';
import 'package:adobe_app/pages/p_website_home.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: must_be_immutable
class Signup extends StatelessWidget {
  Signup({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfController = TextEditingController();

  bool signUpStarted = false;

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

    signUpStarted = true;
    try {
      AuthManager auth = AuthManager.instance;
      await auth.signUp(emailController.text, passwordController.text);

      // ignore: use_build_context_synchronously
      Nav.go(context, "/");
    } on AuthException catch (e) {
      SnackBar snackBar = SnackBar(content: Text(e.message));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    signUpStarted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
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
                    text: "Register: ",
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
                      if(!signUpStarted){
                        signUp(context);
                      }
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