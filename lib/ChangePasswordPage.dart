import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController recoveryController = TextEditingController();

  bool _isLoading = false;
  bool _askForRecovery = false;
  bool _isVerified = false;
  String? _storedEmail;
  String? _storedPhone;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("auth_token");

    final response = await http.get(
      Uri.parse('http://localhost:5000/user/details'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _storedEmail = data['email'];
        _storedPhone = data['phone'];
      });
    }
  }

  Future<void> _verifyCredentials() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/verify-password'),
        body: jsonEncode({'password': oldPasswordController.text}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isVerified = true;
          _askForRecovery = false;
        });
      } else {
        setState(() => _askForRecovery = true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInputs() {
    if (!_isVerified && _askForRecovery) {
      if (recoveryController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your recovery information')),
        );
        return false;
      }
      if (recoveryController.text != _storedEmail && 
          recoveryController.text != _storedPhone) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recovery information does not match')),
        );
        return false;
      }
      _isVerified = true;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return false;
    }

    return true;
  }

  Future<void> _changePassword() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("auth_token");

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000//user/change-password'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'old_password': _isVerified ? oldPasswordController.text : null,
          'recovery_info': _askForRecovery ? recoveryController.text : null,
          'new_password': newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _verifyCredentials,
                    child: const Text('Verify'),
                  ),
                ],
              ),
              if (_askForRecovery) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: recoveryController,
                  decoration: const InputDecoration(
                    labelText: 'Registered Email or Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                enabled: _isVerified,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                enabled: _isVerified,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue.shade900,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}