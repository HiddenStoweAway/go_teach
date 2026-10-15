import 'package:adobe_app/pages/p_auth/p_login.dart';
import 'package:adobe_app/pages/p_auth/p_signup.dart';
import 'package:adobe_app/pages/p_user/p_classroom.dart';
import 'package:adobe_app/pages/p_user/p_teacher_dash.dart';
import 'package:adobe_app/pages/p_user/p_user.dart';
import 'package:adobe_app/pages/p_website_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
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
    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final loggedIn = Supabase.instance.client.auth.currentSession != null;
        final loc = state.matchedLocation;

        final needsLogin = loc.startsWith('/class') || loc == '/dashboard';
        if (needsLogin && !loggedIn) return '/login';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const WebHomePage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/about', builder: (context, state) => const GoalPage()),
        GoRoute(path: '/register', builder: (context, state) => Signup()),
        GoRoute(
          path: '/contact',
          builder: (context, state) => const ContactPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const UserPage(),
        ),
        GoRoute(
          path: '/dashboard/created-classes/:classId',
          builder: (context, state) {
            final classId = state.pathParameters['classId']!;
            return TeacherDashboardPage(classId: classId);
          },
        ),
        GoRoute(
          path: '/dashboard/joined-classes/:classId',
          builder: (context, state) {
            final classId = state.pathParameters['classId']!;
            return ClassroomPage(classId: classId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'LEALO',
      routerConfig: router,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 126, 167, 255),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
