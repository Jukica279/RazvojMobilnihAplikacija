import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:dailyflow/database/database.dart';

class UserProfile {
  final String username;
  final Uint8List picture;

  UserProfile({required this.username, required this.picture});
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<UserProfile> _userProfile;

  @override
  void initState() {
    super.initState();
    // Inicijalizacija _userProfile
    _userProfile = fetchProfile('Barack Obama');
  }

  Future<UserProfile> fetchProfile(String username) async {
    // Simulacija dohvaćanja profila
    await Future.delayed(const Duration(seconds: 2)); // Simulacija kašnjenja
    return UserProfile(
      username: username,
      picture: Uint8List(0), // Postavite odgovarajuću sliku
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Column(
        children: [
          // Profilna slika i korisničko ime
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<UserProfile>(
              future: _userProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No data available.'));
                } else {
                  final profile = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      profile.picture.isNotEmpty
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(profile.picture),
                            )
                          : const Icon(
                              Icons.account_circle,
                              size: 100,
                              color: Colors.grey,
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
                  );
                }
              },
            ),
          ),
          // Additional profile details can be added here
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false, false, false, true],
      ),
    );
  }
}
