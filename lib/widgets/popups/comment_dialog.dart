import 'package:dailyflow/database/database.dart';
import 'package:flutter/material.dart';

class CommentDialog extends StatefulWidget {
  final Recipe recipe;
  final String userEmail;
  final Function(String) onAddComment;

  const CommentDialog({
    required this.recipe,
    required this.userEmail,
    required this.onAddComment,
    Key? key,
  }) : super(key: key);

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<String>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    // Dohvaćanje komentara iz baze
    _commentsFuture = _databaseHelper.fetchComments(widget.recipe.id);
  }

  Future<void> _addComment() async {
    String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      await _databaseHelper.addComment(
          widget.recipe.id, comment, widget.userEmail);

      setState(() {
        _commentsFuture = _databaseHelper.fetchComments(widget.recipe.id);
      });

      widget.onAddComment(comment);
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
            // Prikaz komentara iz baze
            FutureBuilder<List<String>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No comments available.');
                }

                final comments = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments
                      .map((comment) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('- $comment'),
                          ))
                      .toList(),
                );
              },
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
