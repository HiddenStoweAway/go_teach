import 'package:adobe_app/pages/p_auth/p_login.dart';
import 'package:adobe_app/pages/p_auth/p_signup.dart';
import 'package:adobe_app/pages/p_user/p_user.dart';
import 'package:adobe_app/pages/p_website_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  final keys = ApiKeys.instance;

  await Supabase.initialize(
    url: keys.supabaseUrl,
    publishableKey: keys.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LEALO',

      initialRoute: '/',
      routes: {
        '/': (context) => WebHomePage(),
        '/contact': (context) => ContactPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => Signup(),
        '/dashboard': (context) => UserPage()
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 126, 167, 255),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
