import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  _AdminApprovalPageState createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  List<dynamic> _pendingUsers = [];
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  /// Fetch pending providers from the backend
  Future<void> _fetchPendingUsers() async {
    const url = 'http://localhost:5000/admin/pending-providers';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("auth_token");

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing authentication token')),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        setState(() {
          _pendingUsers = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  /// Approve or reject a provider
  Future<void> _approveUser(int userId, String status) async {
    const url = 'http://localhost:5000/admin/approve-provider';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("auth_token");

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing authentication token')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"userId": userId, "status": status}),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User $status successfully')),
        );
        _fetchPendingUsers(); // Refresh list after action
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      print("Error approving user: $e"); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh button
            onPressed: _fetchPendingUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _pendingUsers.isEmpty
              ? const Center(child: Text('No pending approvals'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${user['first_name']} ${user['last_name']}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Email: ${user['email']}",
                                style: const TextStyle(fontSize: 16)),
                            Text("Phone: ${user['phone_number']}",
                                style: const TextStyle(fontSize: 16)),
                            Text("DOB: ${user['dob']}",
                                style: const TextStyle(fontSize: 16)),
                            Text("Address: ${user['address']}",
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _approveUser(user['id'], "Approved"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text("Approve"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _approveUser(user['id'], "Rejected"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text("Reject"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
