import 'package:flutter/material.dart';

class SearchedUser extends StatelessWidget {
  final String mail;
  final String name;

  const SearchedUser({super.key, required this.mail, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          color: Colors.red, // Placeholder red box
          child: const Center(child: Text('IMG')),
        ),
        title: Text(name),
        subtitle: const Text('Tap to view profile'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Navigate to user profile page with this.id
          print('Navigating to user $mail');
        },
      ),
    );
  }
}
