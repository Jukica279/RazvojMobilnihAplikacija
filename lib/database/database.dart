import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  // Connection settings
  final ConnectionSettings settings = ConnectionSettings(
    host: 'ucka.veleri.hr',
    port: 3306, // Default MySQL port
    user: 'lmajetic',
    password: '11',
    db: 'lmajetic',
  );

  Future<MySqlConnection> connect() async {
    // Establish a connection to the database
    return await MySqlConnection.connect(settings);
  }

  Future<List<Recipe>> fetchRecipes() async {
    final connection = await connect();
    try {
      final results = await connection.query(
          'SELECT SifraRecepta,NazivRecepta,OpisRecepta, OznakeRecepta FROM Recept');
      return results.map((row) {
        return Recipe(
          id: row['SifraRecepta'] as int,
          name: row['NazivRecepta'] as String,
          description: row['OpisRecepta'] as String?,
          tags: row['OznakeRecepta'] as String?,
        );
      }).toList();
    } finally {
      await connection.close();
    }
  }

  Future<List<User>> fetchUsers(String query) async {
    final connection = await connect();
    try {
      final results = await connection.query(
        'SELECT KorisnickoIme,EmailKorisnika FROM Korisnik WHERE KorisnickoIme LIKE ?',
        ['%$query%'],
      );
      return results.map((row) {
        return User(
          mail: row['EmailKorisnika'] as String,
          username: row['KorisnickoIme'] as String,
        );
      }).toList();
    } finally {
      await connection.close();
    }
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

class User {
  final String mail;
  final String username;

  User({
    required this.mail,
    required this.username,
  });
}
