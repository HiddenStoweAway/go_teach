import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiManager {
  static final GeminiManager instance = GeminiManager();
  final gem = Gemini.instance;

  Future<String> getResponse(String prompt) async {
    
    final my_prompt = await gem.prompt(parts: [
      Part.text(
        prompt
      ),
    ]);

    return my_prompt?.output ?? "Error getting response";
  }
}