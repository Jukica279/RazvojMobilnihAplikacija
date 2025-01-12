import 'package:dailyflow/widgets/popups/comment_dialog.dart';
import 'package:dailyflow/widgets/navigationBar.dart';
import 'package:dailyflow/widgets/popups/recepie_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:dailyflow/database/database.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Map<int, bool> _showComments = {};
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _fetchRecipes();
  }

  // Define _fetchRecipes here to fetch recipes
  Future<List<Recipe>> _fetchRecipes() async {
    try {
      List<Recipe> recipes = await _databaseHelper.fetchRecipes();
      return recipes;
    } catch (e) {
      print("Error fetching recipes: $e");
      return [];
    }
  }

  void _addComment(Recipe recipe, String comment) {
    setState(() {
      recipe.comments.add(comment);
    });
  }

  void _toggleVisibility(int recipeId) {
    setState(() {
      _showComments[recipeId] = !(_showComments[recipeId] ?? false);
    });
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
            /*  const SizedBox(height: 10),
            const Text(
              'Our Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Expanded(
                child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(45.328979, 14.457664), // Default to San Francisco
                zoom: 12,
              ),
            )), */
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

                      return GestureDetector(
                        onTap: () {
                          // Open recipe details in a dialog
                          showDialog(
                            context: context,
                            builder: (context) => RecipeDetailsDialog(
                              recipe: recipe, // Pass the recipe to the dialog
                            ),
                          );
                        },
                        child: Card(
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
                                      icon: Icon(Icons.comment_outlined),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => CommentDialog(
                                              recipe: recipe,
                                              onAddComment: (comment) {
                                                _addComment(recipe, comment);
                                              }),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
}
