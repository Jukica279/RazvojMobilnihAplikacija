import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:dailyflow/database/database.dart'; // Import the database where Profile is defined

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Instance of DatabaseHelper
  late Future<List<Profile>> _userProfiles;
  String currentEmail = 'user1@gmail.com'; // Default email for the initial user

  @override
  void initState() {
    super.initState();
    _userProfiles = _databaseHelper.fetchProfile(currentEmail); // Fetch profile based on initial email
  }

  void _showSwitchUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Switch User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true, // Hide password input
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Get the email and password entered by the user
                final username = emailController.text;
                final password = passwordController.text;

                // Call the switchUser API to verify the credentials
                bool isValidUser = await _databaseHelper.switchUser(username, password);

                // If the credentials are valid, show a "yes" message, otherwise show "no"
                Navigator.pop(context); // Close the dialog first

                if (isValidUser) {
                  // Get the email for the new user from the database after verification
                  final userProfiles = await _databaseHelper.fetchUsers(username);
                  if (userProfiles.isNotEmpty) {
                    setState(() {
                      currentEmail = userProfiles.first.mail; // Set new email
                      _userProfiles = _databaseHelper.fetchProfile(currentEmail); // Fetch the profile with the new email
                    });
                  }
                } else {
                  // Show "no" message using SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid username or password')),
                  );
                }
              },
              child: const Text('Log in'),
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
        title: const Text('User Profile'),
        actions: [
          TextButton(
            onPressed: _showSwitchUserDialog,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            child: const Text('Switch User'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Profile>>(
          future: _userProfiles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available.'));
            } else {
              final profile = snapshot.data!.first; // Assuming it returns a single profile
              return Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.1,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.account_circle,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Create button
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.3,
                    left: 0,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your "Create" button functionality here
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      ),
                      child: const Text(
                        '+ Create Recipe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false, false, false, true],
      ),
    );
  }
}
