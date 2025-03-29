import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sinolta_new/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.blue[900],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                'Login',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 30),
              _buildTextField(emailController, 'User ID', Icons.email),
              const SizedBox(height: 15),
              _buildTextField(passwordController, 'Password', Icons.lock,
                  obscureText: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    const Text('Login', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Future<void> _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email and Password cannot be empty.');
      return;
    }

    var serverName = "184.69.220.230";
    var portNumber = "82";
    var projectName = "SinoltaCloudAuthentication";
    var url =
        "http://$serverName:$portNumber/Sinolta/$projectName/SinoltaApi/TriggerBusinessWorkflow";

    var workflowRequest = {
      "AuthorizationKey": "SinoltaBypassApiKey",
      "UserName": email,
      "Password": password,
      "DeviceSerialNumber": "6FE0340TES",
      "MAC": ""
    };

    var workFlowName = "Logic.CloudAuthentication.LogicAppLogin";

    var request = {
      "Project": projectName,
      "BusinessWorkflow": workFlowName,
      "WorkflowRequest": jsonEncode(workflowRequest),
      "BlockingDelay": 5
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request),
      );

      print('Response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data != null && data['Status'] == 'Success') {
          var workflowResponse = jsonDecode(data['WorkflowResponse']);

          if (workflowResponse['ValidRequest'] == 'True' &&
              workflowResponse['OutcomeCase'] == '1') {
            var sessionId = workflowResponse['AppSessionId'];
            _showSuccessDialog(
                'Login Successful', workflowResponse['StatusMessage']);

            // Pass the sessionId to the HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(sessionId: sessionId)),
            );
          } else {
            _showErrorDialog(
                workflowResponse['StatusMessage'] ?? 'Unknown error');
          }
        } else {
          _showErrorDialog('Unexpected server response');
        }
      } else {
        _showErrorDialog('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
