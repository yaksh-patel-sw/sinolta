import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'connectionScreen.dart';

class HomeScreen extends StatefulWidget {
  final String sessionId;

  const HomeScreen({super.key, required this.sessionId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  List<Map<String, String>> projectList = [];
  final String _settingsPin = "1234"; // Predefined PIN for Settings

  @override
  void initState() {
    super.initState();
    fetchProjectList();
  }

  Future<void> fetchProjectList() async {
    const serverName = "184.69.220.230";
    const portNumber = "82";
    const projectName = "SinoltaCloudAuthentication";
    final url = Uri.parse(
        "http://$serverName:$portNumber/Sinolta/$projectName/SinoltaApi/TriggerBusinessWorkflow");

    final requestPayload = {
      "AuthorizationKey": "SinoltaBypassApiKey",
      "UserName": "TestUser1",
      "SessionId": widget.sessionId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Project": projectName,
          "BusinessWorkflow": "Logic.CloudAuthentication.LogicListOfProjects",
          "WorkflowRequest": jsonEncode(requestPayload),
          "BlockingDelay": 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['WorkflowResponse'] != null) {
          final workflowResponse = jsonDecode(data['WorkflowResponse']);
          final projectIds =
              (workflowResponse['ProjectIds'] as String).split(",");
          final projectNames =
              (workflowResponse['ProjectNames'] as String).split(",");

          if (projectIds.length == projectNames.length) {
            setState(() {
              projectList = List<Map<String, String>>.generate(
                  projectIds.length, (index) {
                return {
                  "id": projectIds[index].trim(),
                  "name": projectNames[index].trim(),
                };
              });
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print("Error: Mismatched ProjectIds and ProjectNames lengths.");
          }
        } else {
          setState(() {
            isLoading = false;
          });
          print("Error: No WorkflowResponse in API response.");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            "Error: Failed to fetch project list. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception: $e");
    }
  }

  Future<void> validateSession() async {
    const serverName = "184.69.220.230";
    const portNumber = "82";
    const projectName = "SinoltaCloudAuthentication";
    final url = Uri.parse(
        "http://$serverName:$portNumber/Sinolta/$projectName/SinoltaApi/TriggerBusinessWorkflow");

    final workflowRequest = {
      "AuthorizationKey": "SinoltaBypassApiKey",
      "UserName": "TestUser1",
      "AppSessionId": widget.sessionId,
    };

    const workFlowName = "Logic.CloudAuthentication.LogicAppCheckUserWebLogin";

    final dataValue = {
      "Project": projectName,
      "BusinessWorkflow": workFlowName,
      "WorkflowRequest": jsonEncode(workflowRequest),
      "BlockingDelay": 30,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataValue),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['WorkflowResponse'] != null) {
          final workflowResponse = jsonDecode(data['WorkflowResponse']);
          final validRequest = workflowResponse['ValidRequest'] ?? "False";
          final statusMessage = workflowResponse['StatusMessage'] ?? "Unknown";

          _showValidationDialog(
              validRequest == "True" ? "" : "Login Authantication Failed",
              statusMessage);
        } else {
          _showValidationDialog("Error", "Invalid response from server.");
        }
      } else {
        _showValidationDialog(
            "Error", "Failed with status code ${response.statusCode}");
      }
    } catch (e) {
      _showValidationDialog("Exception", e.toString());
    }
  }

  Future<void> selectProject(String projectId, String projectName) async {
    print("pro: $projectId");
    print("name: $projectName");
    const serverName = "184.69.220.230";
    const portNumber = "82";
    final url = Uri.parse(
        "http://$serverName:$portNumber/Sinolta/SinoltaCloudAuthentication/SinoltaApi/TriggerBusinessWorkflow");

    final workflowRequest = {
      "AuthorizationKey": "SinoltaBypassApiKey",
      "UserName": "TestUser1",
      "SessionId": widget.sessionId,
      "ProjectId": projectId,
      "ProjectName": projectName,
    };

    const workFlowName = "Logic.CloudAuthentication.LogicSelectProject";

    final dataValue = {
      "Project": "SinoltaCloudAuthentication",
      "BusinessWorkflow": workFlowName,
      "WorkflowRequest": jsonEncode(workflowRequest),
      "BlockingDelay": 30,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataValue),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['Status'] == "Success" &&
            data.containsKey('WorkflowResponse')) {
          final workflowResponseString = data['WorkflowResponse'];
          try {
            final workflowResponse = jsonDecode(workflowResponseString);
            final projectUrl = workflowResponse['ProjectUrl'] ?? '';
            if (Uri.parse(projectUrl).isAbsolute) {
              _showProjectUrlDialog(projectUrl);
            } else {
              _showProjectUrlDialog("Error: Invalid Project URL format.");
            }
          } catch (e) {
            _showProjectUrlDialog("Error parsing WorkflowResponse: $e");
          }
        } else {
          _showProjectUrlDialog(
              "Error: ${data['StatusMessage'] ?? 'Unknown error'}");
        }
      } else {
        _showProjectUrlDialog(
            "Error selecting project: ${response.statusCode}");
      }
    } catch (e) {
      _showProjectUrlDialog("Exception: $e");
    }
  }

  void _showProjectUrlDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Project Info'),
          content: Text(message),
          actions: [
            if (Uri.parse(message).isAbsolute)
              TextButton(
                child: const Text('Open URL'),
                onPressed: () {
                  _launchURL(message);
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _verifyAndEnterSettings() {
    showDialog(
      context: context,
      builder: (context) {
        String inputPin = "";
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            onChanged: (value) {
              inputPin = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter PIN',
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (inputPin == _settingsPin) {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 1;
                  });
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect PIN. Access Denied.'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showValidationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _verifyAndEnterSettings();
    } else if (index == 2) {
      _showValidationConfirmationDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showValidationConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validation Confirmation'),
          content: const Text('Are you trying to connect to the webpage?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                validateSession(); // Call the API
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: projectList.length,
                  itemBuilder: (context, index) {
                    final project = projectList[index];
                    return ListTile(
                      title: Text(project['name']!),
                      onTap: () =>
                          selectProject(project['id']!, project['name']!),
                    );
                  },
                )
          : const ConnectionScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Project List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Validate',
          ),
        ],
      ),
    );
  }
}
