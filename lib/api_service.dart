import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String apiUrl = "http://10.0.2.2:5000"; // Use 127.0.0.1 for iOS/Web

  static Future<String?> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['token']; // Return JWT token
    } else {
      return null; // Login failed
    }
  }
}
