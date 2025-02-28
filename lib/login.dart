import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'transit_provider.dart';
import 'pending_approval.dart';
import 'admin.dart';
import 'newreg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String username = '';
  late String password = '';
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// Import this

Future<void> _submitForm() async {
  final form = _formKey.currentState;
  if (form!.validate()) {
    form.save();
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData.containsKey('token')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', responseData['token']); // Store token
          await prefs.setString('refresh_token', responseData['refreshToken']); // Store refresh token
          await prefs.setString('role', responseData['role']); // Store role
          await prefs.setString('status', responseData['status']); // Store status

          print("Token stored: ${responseData['token']}");

          // ✅ Navigate based on role
          if (responseData['role'] == 'Admin') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const AdminPage()));
          } else if (responseData['role'] == 'Transit Rider') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomePage()));
          } else if (responseData['role'] == 'Transit Provider') {
            if (responseData['status'] == 'Approved') {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const TransitProviderPage()));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const PendingApprovalPage()));
            }
          } else {
            _showErrorDialog("Invalid user role.");
          }
        } else {
          _showErrorDialog("Invalid response from server.");
        }
      } else {
        // 🛑 Better error handling
        final String errorMessage =
            responseData.containsKey('message') ? responseData['message'] : "Login failed.";
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog("Login failed. Please check your internet connection and try again.");
    }

    setState(() => isLoading = false);
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your username' : null,
                  onSaved: (value) => username = value!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your password' : null,
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Login'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/newreg');
                            },
                            child: const Text('New Registration'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginPage(),
      '/homepage': (context) => const HomePage(),
      '/newreg': (context) => const SignUpPage(),
      '/transit_provider': (context) => const TransitProviderPage(),
      '/pending_approval': (context) => const PendingApprovalPage(),
      '/admin': (context) => const AdminPage(),
    },
  ));
}
