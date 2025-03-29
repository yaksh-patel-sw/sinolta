// connection_screen.dart

import 'package:flutter/material.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  String serverAddress = '184.69.220.230';
  String portNumber = '82';
  String authorizationKey = 'SinoltaBypassApiKey';
  String projectName = 'SinoltaCloudAuthentication';

  final TextEditingController serverAddressController = TextEditingController();
  final TextEditingController portNumberController = TextEditingController();
  final TextEditingController authorizationKeyController =
      TextEditingController();
  final TextEditingController projectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    serverAddressController.text = serverAddress;
    portNumberController.text = portNumber;
    authorizationKeyController.text = authorizationKey;
    projectNameController.text = projectName;
  }

  void saveDetails() {
    setState(() {
      serverAddress = serverAddressController.text;
      portNumber = portNumberController.text;
      authorizationKey = authorizationKeyController.text;
      projectName = projectNameController.text;
    });
    Navigator.pop(context); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
                controller: serverAddressController, label: 'Server Address'),
            const SizedBox(height: 15),
            _buildTextField(
                controller: portNumberController, label: 'Port Number'),
            const SizedBox(height: 15),
            _buildTextField(
                controller: authorizationKeyController,
                label: 'Authorization Key'),
            const SizedBox(height: 15),
            _buildTextField(
                controller: projectNameController, label: 'Project Name'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveDetails,
              child: const Text('Save Connection Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
