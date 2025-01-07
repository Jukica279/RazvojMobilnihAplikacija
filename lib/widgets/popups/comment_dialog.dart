import 'package:dailyflow/database/database.dart';
import 'package:flutter/material.dart';

class CommentDialog extends StatelessWidget {
  final Recipe recipe;
  final TextEditingController _commentController = TextEditingController();

  CommentDialog({required this.recipe, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Comment'),
      content: TextField(
        controller: _commentController,
        decoration: const InputDecoration(hintText: 'Enter your comment'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_commentController.text.isNotEmpty) {
              // Add the comment to the recipe
              recipe.comments.add(_commentController.text);
            }
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
