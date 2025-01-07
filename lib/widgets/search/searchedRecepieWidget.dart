import 'package:dailyflow/database/database.dart';
import 'package:dailyflow/widgets/popups/recepie_details_dialog.dart';
import 'package:flutter/material.dart';

class SearchedRecipe extends StatelessWidget {
  final int id;
  final String name;
  final String description; // Assuming description is part of the recipe.
  final String tags; // Assuming tags are part of the recipe.

  const SearchedRecipe({
    super.key, 
    required this.id, 
    required this.name,
    required this.description, 
    required this.tags
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
          // Show recipe details dialog on tap
          showDialog(
            context: context,
            builder: (context) => RecipeDetailsDialog(
              recipe: Recipe(id: id, name: name, description: description, tags: tags),
            ),
          );
        },
      ),
    );
  }
}
