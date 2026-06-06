import 'package:adobe_app/managers/auth_manager.dart';
import 'package:adobe_app/managers/gemini_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keys = ApiKeys.instance;

  await Supabase.initialize(url: keys.supabaseUrl, anonKey: keys.anonKey);
  Gemini.init(apiKey: keys.gemini);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 126, 167, 255),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: AuthManager.instance.authGate(),
    );
  }
}
