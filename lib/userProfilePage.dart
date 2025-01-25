import 'package:flutter/material.dart';
import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:dailyflow/database/database.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Profile>> _userProfiles;
  String currentEmail = 'user1@gmail.com';

  // Postavljanje pocetnog profila za User 1
  @override
  void initState() {
    super.initState();
    _userProfiles = _databaseHelper.fetchProfile(currentEmail);
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
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = emailController.text;
                final password = passwordController.text;

                bool isValidUser = await _databaseHelper.switchUser(username, password);

                Navigator.pop(context);
                //dohvat i provjera unesenog racuna
                if (isValidUser) {
                  final userProfiles = await _databaseHelper.fetchUsers(username);
                  if (userProfiles.isNotEmpty) {
                    setState(() {
                      currentEmail = userProfiles.first.mail;
                      _userProfiles = _databaseHelper.fetchProfile(currentEmail);
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('False Username or Password')),
                  );
                }
              },
              child: const Text('Log in'),
            ),
          ],
        );
},);}

  void _showCreateRecipeDialog() {
    final nazivReceptaController = TextEditingController();
    final opisReceptaController = TextEditingController();
    final oznakeReceptaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Recipe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nazivReceptaController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                ),
              ),
              TextField(
                controller: opisReceptaController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Description',
                ),
                maxLines: 3,
              ),
              TextField(
                controller: oznakeReceptaController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Tags',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nazivRecepta = nazivReceptaController.text;
                final opisRecepta = opisReceptaController.text;
                final oznakeRecepta = oznakeReceptaController.text;

                if (nazivRecepta.isEmpty || opisRecepta.isEmpty || oznakeRecepta.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all the fields.')),
                  );
                  return;
                }

                bool success = await _databaseHelper.insertRecipe(
                  nazivRecepta,
                  opisRecepta,
                  oznakeRecepta,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Recipe "$nazivRecepta" has been created'
                        : 'Failed to create recipe.'),
                  ),
                );
              },
              child: const Text('Create Recipe'),
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
              final profile = snapshot.data!.first;
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
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.3,
                    left: 0,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: _showCreateRecipeDialog,
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
