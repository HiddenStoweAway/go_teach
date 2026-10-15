import 'package:adobe_app/managers/auth_manager.dart';
import 'package:adobe_app/managers/mynav.dart';
import 'package:adobe_app/pages/p_website_home.dart';
import 'package:adobe_app/widgets/text_field.dart';
import 'package:adobe_app/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool signInStarted = false;

  void signIn(BuildContext context) async {
    signInStarted = true;
    try {
      final auth = AuthManager.instance;

      await auth.signIn(emailController.text, passwordController.text);

      Nav.go(context, "/");
    } on AuthException catch (e) {
      SnackBar snackBar = SnackBar(content: Text(e.message));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    signInStarted = false;
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
                  MyTitle(text: "Enter your credentials: ", fontSize: 18),

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

                  SizedBox(height: 35),

                  // SUBMIT BUTTON
                  GestureDetector(
                    onTap: () {
                      if (!signInStarted) {
                        signIn(context);
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: MyTitle(
                          text: "Login!",
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Text("Don't Have An Account? "),
                  TextButton(
                    onPressed: () {
                      Nav.go(context, "/register");
                    },
                    child: Text(
                      "Sign Up!",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
