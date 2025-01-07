import 'package:dailyflow/database/database.dart';
import 'package:flutter/material.dart';

class RecipeDetailsDialog extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsDialog({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(recipe.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.description != null && recipe.description!.isNotEmpty)
              Text(
                'Description:\n${recipe.description!}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),
            if (recipe.tags != null && recipe.tags!.isNotEmpty)
              Text(
                'Tags: ${recipe.tags}',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
