// ignore_for_file: sort_child_properties_last, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'route_map_page.dart'; // Import the RouteMapPage
import 'package:image_picker/image_picker.dart';

class BusOwnerDetailsPage extends StatefulWidget {
  @override
  _BusOwnerDetailsPageState createState() => _BusOwnerDetailsPageState();
}

class _BusOwnerDetailsPageState extends State<BusOwnerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String vehicleRegNo,
      chassisNo,
      engineNo,
      vehicleMakeModel,
      ownerName,
      ownerAddress;
  List<String> uploadedDocuments = []; // To store document paths

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus & Owner Details'),
        backgroundColor: Color(0xFF003366), // Deep Blue
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                'Enter the required information and upload necessary documents.',
                style: TextStyle(color: Color(0xFF95A5A6), fontSize: 16)),
            SizedBox(height: 20),
            _buildForm(),
            SizedBox(height: 20),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          // Left Column
          Expanded(child: _buildLeftColumnForm()),
          SizedBox(width: 20),
          // Right Column
          Expanded(child: _buildRightColumnForm()),
        ],
      ),
    );
  }

  Widget _buildLeftColumnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
            'Vehicle Registration Number', (value) => vehicleRegNo = value!),
        _buildTextField('Chassis Number', (value) => chassisNo = value!),
        _buildTextField('Engine Number', (value) => engineNo = value!),
        _buildTextField(
            'Vehicle Make and Model', (value) => vehicleMakeModel = value!),
        _buildTextField('Owner\'s Name', (value) => ownerName = value!),
        _buildTextField('Owner\'s Address', (value) => ownerAddress = value!),
      ],
    );
  }

  Widget _buildRightColumnForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Insurance Details', (value) {}),
        _buildTextField('Fitness Certificate', (value) {}),
        _buildTextField('Permit Details', (value) {}),
        _buildFileUploadButton1(),
        _buildFileUploadButton2(),
        _buildFileUploadButton(),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String?)? onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Color(0xFFE3E4E8), // Subtle Gray
        ),
      ),
    );
  }

  Widget _buildFileUploadButton1() {
    return _buildUploadButton('Upload Documents (RC)', _pickFiles1);
  }

  Future<void> _pickFiles1() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );

    if (result != null) {
      setState(() {
        uploadedDocuments = result.paths.map((path) => path!).toList();
      });
    }
  }

  Widget _buildFileUploadButton2() {
    return _buildUploadButton('Upload Documents (License)', _pickFiles2);
  }

  Future<void> _pickFiles2() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );

    if (result != null) {
      setState(() {
        uploadedDocuments = result.paths.map((path) => path!).toList();
      });
    }
  }

  Widget _buildFileUploadButton() {
    return _buildUploadButton('Upload Documents (ID Proof)', _pickFiles);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );

    if (result != null) {
      setState(() {
        uploadedDocuments = result.paths.map((path) => path!).toList();
      });
    }
  }

  // Reusable button creation function with uniform styles
  Widget _buildUploadButton(String label, Future<void> Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Color(0xFF28A745), // Green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0), // Consistent padding
        ),
      ),
    );
  }

  Widget _buildSubmitSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSubmitButton(),
        _buildCancelButton(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Text('Submit'),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(150, 50),
          backgroundColor: Color(0xFF003366), // Deep Blue
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0), // Consistent padding
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/transit_provider',
            (route) => false,
          );
        },
        child: Text('Cancel'),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(150, 50), backgroundColor: Color(0xFFDC3545), // Red
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0), // Consistent padding
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Now navigate to the route mapping page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RouteMapPage()),
      );
    }
  }
}
