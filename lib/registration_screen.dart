import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'connectionScreen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  File? selfieImageFile;
  File? driverLicenseImageFile;

  // Hardcoded values
  final String hardcodedPhoneNumber = "123456789";
  final String serverName = "184.69.220.230";
  final String portNumber = "82";
  final String projectName = "SinoltaCloudAuthentication";

  final picker = ImagePicker();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(emailController, 'Email ID', Icons.email),
              const SizedBox(height: 15),
              _buildTextField(usernameController, 'Username', Icons.person),
              const SizedBox(height: 15),
              _buildTextField(passwordController, 'Password', Icons.lock,
                  obscureText: true),
              const SizedBox(height: 15),
              _buildTextField(
                  confirmPasswordController, 'Confirm Password', Icons.lock,
                  obscureText: true),
              // const SizedBox(height: 15),
              // _buildImageButton(
              //     'Select Selfie Image', _pickSelfieImage, selfieImageFile),
              // const SizedBox(height: 15),
              // _buildImageButton('Select Government ID', _pickDriverLicenseImage,
              //     driverLicenseImageFile),
              const SizedBox(height: 30),
              _buildElevatedButton('Register', _registerUser),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _askPasscode,
        backgroundColor: Colors.white,
        child: Icon(Icons.settings, color: Colors.blue[900]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // TextField Widget
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          prefixIcon: Icon(icon, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        ),
      ),
    );
  }

  // Image button widget
  // Widget _buildImageButton(
  //     String label, VoidCallback onPressed, File? imageFile) {
  //   return ElevatedButton(
  //     onPressed: onPressed,
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.white,
  //       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(label, style: const TextStyle(color: Colors.blue)),
  //         if (imageFile != null)
  //           const Padding(
  //             padding: EdgeInsets.only(left: 8.0),
  //             child: Icon(Icons.check, color: Colors.green),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // General elevated button widget
  Widget _buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.blue)),
    );
  }

  Future<void> _pickSelfieImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List fileData = await pickedFile.readAsBytes(); // Read as bytes
      String selfieBase64 = base64Encode(fileData); // Encode to Base64
      setState(() {
        selfieImageFile =
            File(pickedFile.path); // Keep the file for UI indication
      });
      print("Selfie Base64: $selfieBase64"); // Debug log
    }
  }

  Future<void> _pickDriverLicenseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List fileData = await pickedFile.readAsBytes(); // Read as bytes
      String driverLicenseBase64 = base64Encode(fileData); // Encode to Base64
      setState(() {
        driverLicenseImageFile =
            File(pickedFile.path); // Keep the file for UI indication
      });
      print("Driver License Base64: $driverLicenseBase64"); // Debug log
    }
  }

  Future<void> _registerUser() async {
    if (_validateFields()) {
      String url =
          "http://$serverName:$portNumber/Sinolta/$projectName/SinoltaApi/TriggerBusinessWorkflow";

      String selfieBase64 = selfieImageFile != null
          ? base64Encode(await selfieImageFile!.readAsBytes())
          : ''; // Default to an empty string if not uploaded

      String driverLicenseBase64 = driverLicenseImageFile != null
          ? base64Encode(await driverLicenseImageFile!.readAsBytes())
          : ''; // Default to an empty string if not uploaded

      var workflowRequest = {
        "AuthorizationKey": "SinoltaBypassApiKey",
        "UserName": usernameController.text,
        "Password": passwordController.text,
        "DeviceSerialNumber": "6FE0340TES",
        "CellNumber": hardcodedPhoneNumber,
        "Email": emailController.text,
        "MAC": "AAAAAAAAAAAAAA",
        "DeviceName": "Device1",
        "SelfieImage": selfieBase64, // Can be empty
        "GovernmentIssuedID": driverLicenseBase64 // Can be empty
      };

      var dataValue = {
        "Project": projectName,
        "BusinessWorkflow": "Logic.CloudAuthentication.LogicAppRegisterDevice",
        "WorkflowRequest": jsonEncode(workflowRequest),
        "BlockingDelay": 30
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dataValue),
        );

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          print("Response Data: $responseData");

          var WorkflowResponse = jsonDecode(responseData['WorkflowResponse']);
          String validRequest = WorkflowResponse['ValidRequest'];
          print("Data: $validRequest");

          String statusMessage = WorkflowResponse['StatusMessage'];
          print("Data: $statusMessage");

          String outcomeCase = WorkflowResponse['OutcomeCase'];
          print("Data: $outcomeCase");

          if (validRequest == "True") {
            _showSuccessDialog("Success: $statusMessage ($outcomeCase)");
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            _showErrorDialog("Error: $statusMessage ($outcomeCase)");
          }
        } else {
          _showErrorDialog('Server error: ($response.statusCode)');
        }
      } catch (error) {
        _showErrorDialog('Error during registration: $error');
      }
    }
  }

  bool _validateFields() {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields.');
      return false;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      _showErrorDialog('Please enter a valid email address.');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match.');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _askPasscode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController passcodeController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Passcode'),
          content: TextField(
            controller: passcodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: 'Enter 6-digit passcode',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                if (passcodeController.text == '864938') {
                  // Hardcoded passcode
                  Navigator.of(context).pop();
                  _navigateToConnectionScreen();
                } else {
                  _showErrorDialog('Invalid passcode');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToConnectionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConnectionScreen()),
    );
  }
}
