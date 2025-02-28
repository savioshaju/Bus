import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? _firstName;
  String? _middleName;
  String? _lastName;
  String? _username;
  String? _email;
  String? _phoneNumber;
  DateTime? _dob;
  String? _address;
  String _role = '';

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordValid(String password) {
    final capitalLetterRegExp = RegExp(r'[A-Z]');
    final numberRegExp = RegExp(r'[0-9]');
    final specialCharacterRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    return capitalLetterRegExp.hasMatch(password) &&
        numberRegExp.hasMatch(password) &&
        specialCharacterRegExp.hasMatch(password) &&
        password.length >= 8;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<bool> _checkDatabaseConnection() async {
    final url = 'http://localhost:5000/check-db';
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    _formKey.currentState?.save();

    final url = 'https://bus-bus-pq2f.onrender.com/signup';


    final response = await http.post(
  Uri.parse(url),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "first_name": _firstName,
    "middle_name": _middleName,
    "last_name": _lastName,
    "username": _username,
    "email": _email,
    "phone_number": _phoneNumber,
    "password": _passwordController.text,
    "dob": _dob!.toIso8601String(),
    "address": _address,
    "role": _role
  }),
);

print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');


    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData["message"])),
      );
      Navigator.pushNamed(context, _role == 'Transit Rider' ? '/homepage' : '/pending_approval');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData["message"])),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildSectionTitle('Name'),
                    _buildNameFields(),
                    _buildSectionTitle('Username'),
                    _buildUsernameField(),
                    _buildSectionTitle('Email'),
                    _buildEmailField(),
                    _buildSectionTitle('Phone Number'),
                    _buildPhoneField(),
                    _buildSectionTitle('Password'),
                    _buildPasswordField(),
                    _buildPasswordRequirements(),
                    _buildConfirmPasswordField(),
                    _buildSectionTitle('Date of Birth'),
                    _buildDateOfBirthField(context),
                    _buildSectionTitle('Address'),
                    _buildAddressField(),
                    _buildSectionTitle('Role'),
                    _buildRoleSelection(),
                    const SizedBox(height: 20.0),
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNameFields() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(hintText: 'First Name'),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your first name';
            }
            return null;
          },
          onSaved: (value) {
            _firstName = value;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(hintText: 'Middle Name (optional)'),
          keyboardType: TextInputType.text,
          onSaved: (value) {
            _middleName = value;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(hintText: 'Last Name'),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your last name';
            }
            return null;
          },
          onSaved: (value) {
            _lastName = value;
          },
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      decoration: const InputDecoration(hintText: 'Enter your username'),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
      onSaved: (value) {
        _username = value;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: const InputDecoration(hintText: 'Enter your email address'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        } else if (!EmailValidator.validate(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      onSaved: (value) {
        _email = value;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      decoration: const InputDecoration(hintText: 'Enter your phone number'),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        return null;
      },
      onSaved: (value) {
        _phoneNumber = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(hintText: 'Enter your password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        } else if (!_isPasswordValid(value)) {
          return 'Password must be at least 8 characters long and include an uppercase letter, a number, and a special character.';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: const InputDecoration(hintText: 'Confirm your password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        } else if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordRequirements() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        'Password must be at least 8 characters long and include an uppercase letter, a number, and a special character.',
        style: TextStyle(fontSize: 12.0, color: Colors.grey),
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            _dob == null ? 'Select your date of birth' : DateFormat('yyyy-MM-dd').format(_dob!),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      decoration: const InputDecoration(hintText: 'Enter your address'),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your address';
        }
        return null;
      },
      onSaved: (value) {
        _address = value;
      },
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Transit Rider'),
          leading: Radio<String>(
            value: 'Transit Rider',
            groupValue: _role,
            onChanged: (value) {
              setState(() {
                _role = value!;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Transit Provider'),
          leading: Radio<String>(
            value: 'Transit Provider',
            groupValue: _role,
            onChanged: (value) {
              setState(() {
                _role = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      child: const Text('Sign Up'),
    );
  }
}
