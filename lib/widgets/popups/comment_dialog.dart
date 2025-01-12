import 'package:dailyflow/database/database.dart';
import 'package:flutter/material.dart';

class CommentDialog extends StatefulWidget {
  final Recipe recipe;
  final Function(String) onAddComment;

  const CommentDialog(
      {required this.recipe, required this.onAddComment, Key? key})
      : super(key: key);

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    // Inicializujemo komentare sa postojećim komentarima recepta
    _comments.addAll(widget.recipe.comments);
  }

  void _addComment() {
    String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      setState(() {
        _comments.add(comment);
      });
      widget.onAddComment(comment); // Poziva funkciju za dodavanje komentara
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Comment'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prikazivanje svih komentara
            for (var comment in _comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('- $comment'),
              ),
            const SizedBox(height: 10),
            // Polje za unos novog komentara
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(hintText: 'Enter your comment'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Zatvori dijalog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _addComment,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
