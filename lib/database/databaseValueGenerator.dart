import 'package:sqflite/sqflite.dart';

class DatabaseValueGenerator {
  // Generate initial data
  Future<void> populateDatabaseIfEmpty(Database db) async {
    // Check if database is empty
    final userCount = await db.rawQuery('SELECT COUNT(*) FROM User');
    if ((userCount[0]['COUNT(*)'] as int?) == 0) {
      await _generateUsers(db);
      await _generateIngredients(db);
      await _generateRecipes(db);
      await _generateComments(db);
    }
  }

  // Generate Users
  Future<void> _generateUsers(Database db) async {
    final List<Map<String, dynamic>> users = [
      {
        'userEmail': 'john.doe@example.com',
        'username': 'johndoe',
        'userImage': 'default_user.png',
        'password': 'password123',
        'userPreferences': 'None'
      },
      {
        'userEmail': 'jane.smith@example.com',
        'username': 'janesmith',
        'userImage': 'default_user.png',
        'password': 'password123',
        'userPreferences': 'Vegetarian'
      }
      // Add more default users as needed
    ];

    final batch = db.batch();
    
    for (var user in users) {
      batch.insert('User', user);
    }
    
    await batch.commit(noResult: true);
  }

  // Generate Ingredients
  Future<void> _generateIngredients(Database db) async {
    final List<Map<String, dynamic>> ingredients = [
      {'ingredientName': 'Tomato', 'ingredientCalories': 18},
      {'ingredientName': 'Chicken Breast', 'ingredientCalories': 165},
      {'ingredientName': 'Rice', 'ingredientCalories': 130},
      {'ingredientName': 'Pasta', 'ingredientCalories': 131},
      {'ingredientName': 'Onion', 'ingredientCalories': 40},
    ];

    final batch = db.batch();
    
    for (var ingredient in ingredients) {
      batch.insert('Ingredient', ingredient);
    }
    
    await batch.commit(noResult: true);
  }

  // Generate Recipes
  Future<void> _generateRecipes(Database db) async {
    final List<Map<String, dynamic>> recipes = [
      {
        'userId': 1,
        'recipeName': 'Chicken Rice',
        'recipeDescription': 'Delicious chicken with rice',
        'recipeTags': 'Dinner, Main Course',
        'recipeRating': 4.5,
        'recipeImage': 'chicken_rice.png'
      },
      {
        'userId': 2,
        'recipeName': 'Vegetarian Pasta',
        'recipeDescription': 'Healthy vegetarian pasta dish',
        'recipeTags': 'Vegetarian, Lunch',
        'recipeRating': 4.0,
        'recipeImage': 'vegetarian_pasta.png'
      }
    ];

    final batch = db.batch();
    
    for (var recipe in recipes) {
      final recipeId = await db.insert('Recipe', recipe);
      
      // Add ingredients to recipe
      batch.insert('RecipeIngredient', {
        'recipeId': recipeId,
        'ingredientId': 2, // Chicken Breast
        'ingredientQuantity': 200.0,
      });
      
      batch.insert('RecipeIngredient', {
        'recipeId': recipeId,
        'ingredientId': 3, // Rice
        'ingredientQuantity': 150.0,
      });
    }
    
    await batch.commit(noResult: true);
  }

  // Generate Comments
  Future<void> _generateComments(Database db) async {
    final List<Map<String, dynamic>> comments = [
      {
        'userId': 1,
        'recipeId': 1,
        'commentText': 'Great recipe! Easy to make.',
        'commentRating': 4.5,
      },
      {
        'userId': 2,
        'recipeId': 2,
        'commentText': 'Delicious and healthy!',
        'commentRating': 4.0,
      }
    ];

    final batch = db.batch();
    
    for (var comment in comments) {
      batch.insert('Comment', comment);
    }
    
    await batch.commit(noResult: true);
  }
}