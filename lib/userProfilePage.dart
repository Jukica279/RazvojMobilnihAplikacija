import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:dailyflow/database/database.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Profile>> _userProfiles;
  String currentEmail = '';

  @override
  void initState() {
    super.initState();
    _userProfiles = Future.value([]);
    _loadCurrentUser();
  }

  // Učitaj korisnički email iz SharedPreferences
  void _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentEmail') ?? 'user1@gmail.com';
    setState(() {
      currentEmail = email;
      _userProfiles = _databaseHelper.fetchProfile(currentEmail);
    });
  }

  // Spremi mail u SharedPreferences
  void _saveCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currentEmail', email);
  }

  // popup za promjenu korisnika
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
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
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

                if (isValidUser) {
                  final userProfiles = await _databaseHelper.fetchUsers(username);
                  if (userProfiles.isNotEmpty) {
                    setState(() {
                      currentEmail = userProfiles.first.mail;
                      _saveCurrentUser(currentEmail);
                      _userProfiles = _databaseHelper.fetchProfile(currentEmail);
                    });
                  }
                } else {
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

  // popup za kreirat recept
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
                decoration: const InputDecoration(labelText: 'Recipe Name'),
              ),
              TextField(
                controller: opisReceptaController,
                decoration: const InputDecoration(labelText: 'Recipe Description'),
                maxLines: 3,
              ),
              TextField(
                controller: oznakeReceptaController,
                decoration: const InputDecoration(labelText: 'Recipe Tags'),
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

                final prefs = await SharedPreferences.getInstance();
                final currentEmail = prefs.getString('currentEmail') ?? 'user1@gmail.com';

                bool success = await _databaseHelper.insertRecipe(
                  nazivRecepta,
                  opisRecepta,
                  oznakeRecepta,
                  currentEmail,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // profil
            Center(
              child: FutureBuilder<List<Profile>>(
                future: _userProfiles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No profile data available.'));
                  } else {
                    final profile = snapshot.data!.first;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/default_profile_picture.png'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
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
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Recipes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _databaseHelper.fetchUsersRecipes(currentEmail),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No recipes available.'));
                  } else {
                    final recipes = snapshot.data!;
                    return ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(recipe.name),
                            subtitle: Text(recipe.description ?? ''),
                            trailing: Text(recipe.tags ?? ''),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false, false, false, true],
      ),
    );
  }
}
