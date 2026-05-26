import 'package:adobe_app/auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassManager {
  final supabase = Supabase.instance.client;
  static ClassManager instance = ClassManager();

  Future<void> addClass(String className) async {
    final auth = AuthManager.instance;
    final currentUser = auth.currentUser();

    if (currentUser == null) {
      return;
    }

    try {
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
    } on PostgrestException catch (e) {
      print(e.message);
    } catch (e) {
      print("other error: $e"); // add this
    }
  }
}
