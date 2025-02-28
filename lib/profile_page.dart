import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'ChangePasswordPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  static const String baseUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          userNameController.text = data['username'] ?? '';
          firstNameController.text = data['first_name'] ?? '';
          middleNameController.text = data['middle_name'] ?? '';
          lastNameController.text = data['last_name'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone_number'] ?? '';
          dobController.text = data['dob'] ?? '';
          addressController.text = data['address'] ?? '';
          _isLoading = false;
        });
        prefs.setString('user_role', data['role']);
      } else {
        _showErrorSnackbar('Failed to load profile: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackbar('Connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$baseUrl/user/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'first_name': firstNameController.text,
          'middle_name': middleNameController.text,
          'last_name': lastNameController.text,
          'phone_number': phoneController.text,
          'dob': dobController.text,
          'address': addressController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _isEditing = false);
        _showSuccessSnackbar('Profile updated successfully');
        await _fetchUserData();
      } else {
        _showErrorSnackbar(
            'Update failed: ${json.decode(response.body)['message']}');
      }
    } catch (e) {
      _showErrorSnackbar('Update error: $e');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/user/delete-account'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        _showErrorSnackbar(
            'Deletion failed: ${json.decode(response.body)['message']}');
      }
    } catch (e) {
      _showErrorSnackbar('Deletion error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Retrieve the user role from SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userRole = prefs.getString(
                'user_role'); // Assuming user role is stored as 'user_role'

            // Navigate based on the user role
            if (userRole == 'Admin') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/admin', // Admin page route
                (route) => false, // Clears all previous pages from the stack
              );
            } else if (userRole == 'Transit Provider') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/transit_provider', // Transit provider page route
                (route) => false, // Clears all previous pages from the stack
              );
            } else if (userRole == 'Transit Rider') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/homepage', // Rider's homepage route
                (route) => false, // Clears all previous pages from the stack
              );
            } else {
              // Default behavior if no role is found
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // If no role found, navigate to login screen
                (route) => false,
              );
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: _isEditing ? buildEditForm() : buildProfileView(),
                  ),
                ),
              ),
            ),
    );
  }

  int _calculateAge(String dob) {
    if (dob.isEmpty) return 0; // Handle empty DOB
    DateTime birthDate = DateTime.parse(dob);
    DateTime today = DateTime.now();

    int age = today.year - birthDate.year;

    // Adjust if the birthday has not occurred yet this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Center(
              child: Text(
                "${userNameController.text} ",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                label: const Text("Edit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        buildDetailRow(
          Icons.person,
          "Name",
          "${firstNameController.text} ${middleNameController.text} ${lastNameController.text}",
        ),
        buildDetailRow(Icons.email, "Email", emailController.text),
        buildDetailRow(Icons.phone, "Phone", phoneController.text),
        buildDetailRow(Icons.calendar_today, "Age",
            "${_calculateAge(dobController.text)} years"),
        buildDetailRow(Icons.home, "Address", addressController.text),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          icon: const Icon(Icons.lock),
          label: const Text("Change Password"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 224, 218, 235),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text("Delete Account"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _confirmDelete,
        ),
      ],
    );
  }

  Widget buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: middleNameController,
                  decoration: const InputDecoration(labelText: 'Middle Name'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            readOnly: true, // Prevent editing
          ),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            readOnly: true, // Prevent editing
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: dobController,
            decoration: const InputDecoration(labelText: 'Date of Birth'),
            readOnly: true,
            onTap: _selectDate,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            maxLines: 3,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Save Changes"),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
