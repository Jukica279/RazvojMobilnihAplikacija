import 'package:dailyflow/database/database.dart';
import 'package:dailyflow/widgets/search/searchedRecepieWidget.dart';
import 'package:dailyflow/widgets/search/searchedUserWidget.dart';
import 'package:flutter/material.dart';
import 'package:dailyflow/widgets/navigationBar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'Recipes'; // Default search type
  List<dynamic> _searchResults = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final List<String> _searchTypeOptions = ['Recipes', 'Users'];

  void _performSearch(String query) async {
    try {
      if (_searchType == 'Recipes') {
        // Fetch recipes from the database
        List<Recipe> allRecipes = await _databaseHelper.fetchRecipes();
        setState(() {
          _searchResults = query.isEmpty
              ? allRecipes
              : allRecipes.where((recipe) => recipe.name.toLowerCase().contains(query.toLowerCase())).toList();
        });
      } else if (_searchType == 'Users') {
        // Fetch users from the database
        List<User> allUsers = await _databaseHelper.fetchUsers('');
        setState(() {
          _searchResults = query.isEmpty
              ? allUsers
              : allUsers.where((user) => user.username.toLowerCase().contains(query.toLowerCase())).toList();
        });
      }
    } catch (e) {
      print('Error performing search: $e');
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch all items initially
    _performSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search Bar and Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Expanded Search TextField
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search ${_searchType == "Recipes" ? "recipes" : "users"}...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: _performSearch,
                  ),
                ),
                const SizedBox(width: 10),

                // Dropdown for Search Type
                DropdownButton<String>(
                  value: _searchType,
                  items: _searchTypeOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _searchType = newValue!;
                      _searchResults = []; // Clear previous results
                      _searchController.clear(); // Clear search field
                      _performSearch(''); // Fetch all items for the new type
                    });
                  },
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
          child: _searchResults.isEmpty
              ? const Center(child: Text('No results found.'))
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    // Assuming that Recipe and User objects have different structures
                    if (_searchType == 'Recipes') {
                      // Assuming Recipe has fields: id, name, description, and tags
                      final recipe = _searchResults[index]; // You should make sure this is a Recipe object
                      return SearchedRecipe(
                        id: recipe.id,
                        name: recipe.name,
                        description: recipe.description, // Pass description
                        tags: recipe.tags, // Pass tags
                      );
                    } else {
                      // Assuming User has fields: mail and username
                      final user = _searchResults[index]; // You should make sure this is a User object
                      return SearchedUser(
                        mail: user.mail,
                        name: user.username, // Pass username as name
                      );
                    }
                  },
                ),
        )

        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false, true, false, false],
      ),
    );
  }
}