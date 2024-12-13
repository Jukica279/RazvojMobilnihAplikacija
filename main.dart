import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:flutter/material.dart';
import 'package:dailyflow/database/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _fetchRecipes();
  }

  Future<List<Recipe>> _fetchRecipes() async {
    final recipeData = await _databaseHelper.getAllRecipes();
    return recipeData.map((data) {
      return Recipe(
        id: data['recipeId'],
        name: data['recipeName'],
        description: data['recipeDescription'],
        tags: data['recipeTags'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe recommendations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _recipesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No recipes available.'),
                    );
                  }

                  final recipes = snapshot.data!;

                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(recipe.description ??
                                  'No description provided.'),
                              const SizedBox(height: 8),
                              Text(
                                recipe.tags ?? '',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      recipe.isLiked
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_alt_outlined,
                                      color:
                                          recipe.isLiked ? Colors.blue : null,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        recipe.isLiked = !recipe.isLiked;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.comment_outlined),
                                    onPressed: () {
                                      _openCommentDialog(context, recipe);
                                    },
                                  ),
                                ],
                              ),
                              if (recipe.comments.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: recipe.comments.map((comment) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 159, 197, 144)),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.grey[100],
                                        ),
                                        child: Text(
                                          "- $comment",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [true, false, false, false],
      ),
    );
  }

  void _openCommentDialog(BuildContext context, Recipe recipe) {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  setState(() {
                    // Add the comment to the list
                    recipe.comments.add(_commentController.text);
                  });
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class Recipe {
  final int id;
  final String name;
  final String? description;
  final String? tags;
  bool isLiked;
  List<String> comments; // Mutable list

  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.tags,
    this.isLiked = false,
    List<String>? comments, // Nullable parameter for initialization
  }) : comments = comments ?? []; // Initialize mutable list
}
