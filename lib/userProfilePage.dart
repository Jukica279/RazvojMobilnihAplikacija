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
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Declare the instance of DatabaseHelper
  late Future<List<Profile>> _userProfiles;

  @override
  void initState() {
    super.initState();
    _userProfiles = _databaseHelper.fetchProfile('johndoe@gmail.com'); // Fetch profile based on mail
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          TextButton(
            onPressed: () {
              // Handle the switch user logic here
              print('Switch User button pressed');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text color
              backgroundColor: Colors.green, // Button background
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
                    top: MediaQuery.of(context).size.height * 0.1, // Position in the upper third
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                      children: [
                        CircleAvatar(
                          radius: 50, // Size the profile picture
                          backgroundColor: Colors.grey[300], // Background color for avatar
                          child: const Icon(
                            Icons.account_circle,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.username, // Display username
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          profile.mail, // Display mail
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
