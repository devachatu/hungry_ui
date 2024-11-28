import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';

class OpenAIService extends GetxController {
  Future<Object> sendMessage(String message) async {
    final url = Uri.parse("https://idp.machint.com/generate_food_test");

    final headers = {
      "Content-Type": "application/json",
    };

    final body = json.encode({
      "prompt": message, // Specify the model (e.g., gpt-3.5-turbo, gpt-4)
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print(response.body);
        final data = json.decode(response.body);
        return json.decode(data["response"]);
      } else {
        throw Exception("Failed to fetch response: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error communicating with OpenAI: $e");
    }
  }
}
