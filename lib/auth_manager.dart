import 'package:adobe_app/pages/p_user/p_user.dart';
import 'package:adobe_app/pages/p_website_home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthManager {
  final supabase = Supabase.instance.client;
  static AuthManager instance = AuthManager();

  Future<User?> signUp(String email, String password) async {
    final AuthResponse res = await supabase.auth.signUp(
      password: password,
      email: email,
    );

    if (res.session != null){
      await supabase.from("users").insert({
        'user_id': res.user!.id,
        'email': res.user!.email,
      });
    }

    return res.user;
  }

  Future<User?> signIn(String email, String password) async {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      password: password,
      email: email,
    );
    final bool emailExists = await supabase
        .from("users")
        .select()
        .eq("email", email)
        .then((o) {
          return o.isNotEmpty;
        });

    if (!emailExists && res.session != null) {
      await supabase.from("users").insert({
        'user_id': res.user!.id,
        'email': res.user!.email,
      });
    }
    return res.user;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? currentUser() {
    return supabase.auth.currentUser;
  }

  Widget authGate() {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data!.session;

        if (session != null) {
          return const UserPage(); // signed in
        } else {
          return WebHomePage(title: 'LEALO'); // signed out
        }
      },
    );
  }
}
