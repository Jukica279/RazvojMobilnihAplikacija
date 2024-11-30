import 'package:flutter/material.dart';

class SearchedRecipe extends StatelessWidget {
  final int id;
  final String name;

  const SearchedRecipe({
    super.key, 
    required this.id, 
    required this.name
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          color: Colors.red,  // Placeholder red box
          child: const Center(child: Text('IMG')),
        ),
        title: Text(name),
        subtitle: const Text('Tap to view recipe details'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Navigate to recipe details page with this.id
          print('Navigating to recipe $id');
        },
      ),
    );
  }
}