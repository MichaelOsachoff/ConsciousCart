import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileLandingPage extends StatefulWidget {
  @override
  _ProfileLandingPageState createState() => _ProfileLandingPageState();
}

class _ProfileLandingPageState extends State<ProfileLandingPage> {
  // Initial values
  String name = '';
  String username = '';
  String email = '';
  String password = '';

  // Controller for editable text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Variable to track the current state
  bool isEditing = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    // Fetch user data when the widget initializes
    fetchUserData();
  }

  // Method to fetch user data from the backend
  Future<void> fetchUserData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/getUserData'));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          name = userData['name'];
          username = userData['username'];
          email = userData['email'];
          password = userData['password'];
        });

        // Set initial values in controllers
        nameController.text = name;
        usernameController.text = username;
        emailController.text = email;
        passwordController.text = password;
      } else {
        // Handle error
        print('Failed to load user data');
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
    }
  }

  // Method to update user data on the backend
  Future<void> updateUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/updateUserData'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text,
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        print('User data updated successfully');
      } else {
        // Handle error
        print('Failed to update user data');
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Toggle the editing state
              setState(() {
                isEditing = !isEditing;
              });

              if (!isEditing) {
                // Save changes when switching from editing to non-editing state
                saveChanges();

                // Update user data on the backend
                updateUserData();
              }
            },
            icon: Icon(isEditing ? Icons.check_rounded : Icons.edit_rounded),
            label: Text(isEditing ? 'Save' : 'Edit'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileField('Name', nameController, !isEditing),
            _buildProfileField('Username', usernameController, !isEditing),
            _buildProfileField('Email', emailController, !isEditing),
            _buildProfileField('Password', passwordController, !isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    bool readOnly,
  ) {
    String passwordMask = '*';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: controller,
                      readOnly: readOnly,
                      obscureText: label == 'Password' && !showPassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    controller == passwordController
                        ? Row(
                            children: [
                              Checkbox(
                                value: showPassword,
                                onChanged: (value) {
                                  setState(() {
                                    showPassword = value!;
                                  });
                                },
                              ),
                              Text('Show password'),
                            ],
                          )
                        : SizedBox(height: 0, width: 0),
                  ],
                )
              : Text(
                  label == 'Password'
                      ? passwordMask * controller.text.length
                      : controller.text,
                  style: TextStyle(fontSize: 18.0),
                ),
        ],
      ),
    );
  }

  void saveChanges() {
    // Update the variables with the new values
    setState(() {
      name = nameController.text;
      username = usernameController.text;
      email = emailController.text;
      password = passwordController.text;
    });
  }
}
