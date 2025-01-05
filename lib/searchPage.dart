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
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      if (_searchType == 'Recipes') {
        // Fetch recipes from the database
        List<Recipe> results = await _databaseHelper.fetchRecipes();
        setState(() {
          _searchResults = results;
        });
      } else if (_searchType == 'Users') {
        // Fetch users from the database
        List<User> results = await _databaseHelper.fetchUsers(query);
        setState(() {
          _searchResults = results;
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
                    });
                  },
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('Start searching...'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return _searchType == 'Recipes'
                          ? SearchedRecipe(
                              id: _searchResults[index].id,
                              name: _searchResults[index].name,
                            )
                          : SearchedUser(
                              mail: _searchResults[index].mail,
                              name: _searchResults[index].username,
                            );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(
        enabledButtons: [false, true, false, false],
      ),
    );
  }
}
