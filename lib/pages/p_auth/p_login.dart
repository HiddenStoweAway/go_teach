import 'package:adobe_app/auth_manager.dart';
import 'package:adobe_app/pages/p_auth/p_signup.dart';
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

  void signIn(BuildContext context) async {
    try{
      final auth = AuthManager.instance;

      await auth.signIn(emailController.text, passwordController.text);
    }
    on AuthException catch (e){
      SnackBar snackBar = SnackBar(content: Text(e.message));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    text: "Enter your credentials: ",
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

                  SizedBox(height: 35),

                  // SUBMIT BUTTON
                  GestureDetector(
                    onTap: () {
                      signIn(context);
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
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (context) => Signup()),
                      );
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
