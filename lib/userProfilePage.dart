import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:flutter/material.dart';



class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile Page'),
      ),
      body: const Center(
        child: Text('Welcome to the User Profile Page!'),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false,false,false,true],
      ),
    );
  }
}
