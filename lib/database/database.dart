import 'package:dailyflow/database/databaseValueGenerator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipe_database.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    // Populate database if empty
    final databaseValueGenerator = DatabaseValueGenerator();
    await databaseValueGenerator.populateDatabaseIfEmpty(db);

    return db;
  }
  Future<void> _createDB(Database db, int version) async {
    // User Table
    await db.execute('''
      CREATE TABLE User (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT NOT NULL UNIQUE,
        username TEXT NOT NULL,
        userImage TEXT,
        password TEXT NOT NULL,
        userPreferences TEXT
      )
    ''');

    // Recipe Table
    await db.execute('''
      CREATE TABLE Recipe (
        recipeId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        recipeDescription TEXT,
        recipeTags TEXT,
        recipeRating REAL,
        recipeName TEXT NOT NULL,
        recipeImage TEXT,
        FOREIGN KEY (userId) REFERENCES User (userId)
      )
    ''');

    // Ingredient Table
    await db.execute('''
      CREATE TABLE Ingredient (
        ingredientId INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredientName TEXT NOT NULL UNIQUE,
        ingredientCalories REAL
      )
    ''');

    // Comment Table
    await db.execute('''
      CREATE TABLE Comment (
        commentId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        recipeId INTEGER,
        commentText TEXT NOT NULL,
        commentRating REAL,
        FOREIGN KEY (userId) REFERENCES User (userId),
        FOREIGN KEY (recipeId) REFERENCES Recipe (recipeId)
      )
    ''');

    // RecipeIngredient Table (Sastojak u receptu)
    await db.execute('''
      CREATE TABLE RecipeIngredient (
        recipeIngredientId INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredientId INTEGER,
        recipeId INTEGER,
        ingredientQuantity REAL,
        FOREIGN KEY (ingredientId) REFERENCES Ingredient (ingredientId),
        FOREIGN KEY (recipeId) REFERENCES Recipe (recipeId)
      )
    ''');
  }

  // User Management Functions
  Future<int> addUser({
    required String email,
    required String username,
    String? userImage,
    required String password,
    String? userPreferences,
  }) async {
    final db = await database;
    return await db.insert('User', {
      'userEmail': email,
      'username': username,
      'userImage': userImage,
      'password': password,
      'userPreferences': userPreferences,
    });
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete('User', where: 'userId = ?', whereArgs: [userId]);
  }

  // Recipe Management Functions
  Future<int> addRecipeWithIngredients({
    required int userId,
    required String recipeName,
    String? recipeDescription,
    String? recipeTags,
    double? recipeRating,
    String? recipeImage,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    final db = await database;

    // Start a transaction to ensure all inserts complete
    return await db.transaction((txn) async {
      // Insert recipe
      final recipeId = await txn.insert('Recipe', {
        'userId': userId,
        'recipeName': recipeName,
        'recipeDescription': recipeDescription,
        'recipeTags': recipeTags,
        'recipeRating': recipeRating,
        'recipeImage': recipeImage,
      });

      // Insert recipe ingredients
      for (var ingredient in ingredients) {
        await txn.insert('RecipeIngredient', {
          'recipeId': recipeId,
          'ingredientId': ingredient['ingredientId'],
          'ingredientQuantity': ingredient['quantity'],
        });
      }

      return recipeId;
    });
  }

  Future<void> deleteRecipe(int recipeId) async {
    final db = await database;
    await db.transaction((txn) async {
      // First delete related recipe ingredients
      await txn.delete('RecipeIngredient', 
        where: 'recipeId = ?', 
        whereArgs: [recipeId]
      );
      
      // Then delete the recipe
      await txn.delete('Recipe', 
        where: 'recipeId = ?', 
        whereArgs: [recipeId]
      );
    });
  }

  // Ingredient Management Functions
  Future<int> addIngredient({
    required String ingredientName,
    double? ingredientCalories,
  }) async {
    final db = await database;
    return await db.insert('Ingredient', {
      'ingredientName': ingredientName,
      'ingredientCalories': ingredientCalories,
    });
  }

  Future<void> deleteIngredient(int ingredientId) async {
    final db = await database;
    await db.delete('Ingredient', 
      where: 'ingredientId = ?', 
      whereArgs: [ingredientId]
    );
  }

  // Comment Management Functions
  Future<int> addComment({
    required int userId,
    required int recipeId,
    required String commentText,
    double? commentRating,
  }) async {
    final db = await database;
    return await db.insert('Comment', {
      'userId': userId,
      'recipeId': recipeId,
      'commentText': commentText,
      'commentRating': commentRating,
    });
  }

  Future<void> deleteComment(int commentId) async {
    final db = await database;
    await db.delete('Comment', 
      where: 'commentId = ?', 
      whereArgs: [commentId]
    );
  }
}

// Example Usage in Flutter
class RecipeService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> createRecipeWithIngredients() async {
    // Example of how to use the addRecipeWithIngredients method
    const userId = 1; // Assume user is logged in
    final recipeIngredients = [
      {
        'ingredientId': 1, // Assume this ingredient exists
        'quantity': 200.0, // 200 grams
      },
      {
        'ingredientId': 2, // Another ingredient
        'quantity': 100.0, // 100 grams
      },
    ];

    await _databaseHelper.addRecipeWithIngredients(
      userId: userId,
      recipeName: 'Delicious Pasta',
      recipeDescription: 'A tasty pasta dish',
      recipeTags: 'Italian, Pasta',
      recipeRating: 4.5,
      ingredients: recipeIngredients,
    );
  }
}