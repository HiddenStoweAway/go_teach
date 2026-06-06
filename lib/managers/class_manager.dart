import 'package:adobe_app/managers/auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

String generateJoinCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(6, (i) => chars[random.nextInt(chars.length)]).join();
}

class ClassManager {
  final supabase = Supabase.instance.client;
  static ClassManager instance = ClassManager();

  Future<void> updateLearningTarget(String classID, String target) async {
    print("RUN");
    try{
      final data = await supabase.from("classes").update({"current_learning_goal": target}).eq("class_id", classID);
    } on PostgrestException catch(e) {
      print(e.message);
    }
    return;
  }

  Future<List<String>> getMyClassNames() async {
    final auth = AuthManager.instance;
    final currentUser = auth.currentUser();

    if (currentUser == null) {
      return ["Couldn't Sign In"];
    }

    try {
      final data = await supabase
          .from("users")
          .select()
          .eq("user_id", currentUser.id);

      return List<String>.from(data.single['classes'] ?? []);
    } on PostgrestException catch (e) {
      print(e.message);
    } catch (e) {
      print("other error: $e"); // add this
    }

    return ["error fetching classes"];
  }

  Future<Map<String, dynamic>> getUserInfo(String userID) async {
    try {
      return await supabase.from('users').select().eq('user_id', userID).single();
    } on PostgrestException catch (e) {
      print(e.message);
    }

    return {"error": "error fetching info"};
  }

  Future<void> addClass(String className) async {
    final auth = AuthManager.instance;
    final currentUser = auth.currentUser();

    if (currentUser == null) {
      return;
    }

    try {
      // ADD CLASS TO USER ROW
      final user = await supabase
          .from("users")
          .select('classes')
          .eq("user_id", currentUser.id)
          .single();

      final List<String> classes = List<String>.from(user['classes'] ?? []);
      classes.add(currentUser.id + className);

      await supabase
          .from("users")
          .update({'classes': classes})
          .eq("user_id", currentUser.id);

      // ADD CLASS TO CLASSES DB
      await supabase.from("classes").insert({
        'class_id': currentUser.id + className,
        'students': [],
        'join_code': generateJoinCode(),
        'owner_id': currentUser.id,
      });
    } on PostgrestException catch (e) {
      print(e.message);
    } catch (e) {
      print("other error: $e"); // add this
    }
  }

  Future<List<String>> getJoinedClassNames() async {
    final auth = AuthManager.instance;
    final currentUser = auth.currentUser();

    if (currentUser == null) {
      return ["Couldn't Sign In"];
    }

    try {
      final data = await supabase
          .from("users")
          .select()
          .eq("user_id", currentUser.id);

      return List<String>.from(data.single['joined_classes'] ?? []);
    } on PostgrestException catch (e) {
      print(e.message);
    } catch (e) {
      print("other error: $e"); // add this
    }

    return ["error fetching classes"];
  }

  // RETURNS AN ERROR DESCRIPTION IF ANY, OTHERWISE DOESN'T RETURN
  Future<String?> joinClass(String code) async {
    final auth = AuthManager.instance;
    final currentUser = auth.currentUser();

    if (currentUser == null) {
      return "Couldn't find signed in user";
    }

    try {
      final codes = await supabase.from("classes").select("join_code");
      if (!codes.any((c) => c['join_code'] == code)) {
        return "Code doesn't exist";
      }

      // ADD STUDENT TO CLASS
      final class_ = await supabase
          .from('classes')
          .select()
          .eq("join_code", code)
          .single();

      List<String> students = List<String>.from(class_['students'] ?? []);
      students.add(currentUser.id);

      await supabase
          .from("classes")
          .update({'students': students})
          .eq("join_code", code);

      // ADD CLASS TO JOINED CLASSES ROW IN STUDENTS

      // ADD CLASS TO USER ROW
      final user = await supabase
          .from("users")
          .select()
          .eq("user_id", currentUser.id)
          .single();

      final List<String> classes = List<String>.from(
        user['joined_classes'] ?? [],
      );
      classes.add(
        Map.from(
          await supabase
              .from("classes")
              .select()
              .eq('join_code', code)
              .single(),
        )['class_id'],
      );

      await supabase
          .from("users")
          .update({'joined_classes': classes})
          .eq("user_id", currentUser.id);
    } on PostgrestException catch (e) {
      print(e.message);
      return e.message;
    } catch (e) {
      print("Other error: $e");
      return "Other error: $e";
    }

    return null;
  }

  Future<Map<String, dynamic>> getClassInfo(String classID) async {
    try {
      final data = await supabase
          .from('classes')
          .select()
          .eq("class_id", classID)
          .single();
      return Map.from(data);
    } on PostgrestException catch (e) {
      print(e.message);
    }

    return {"error": "error fetching info"};
  }
}
