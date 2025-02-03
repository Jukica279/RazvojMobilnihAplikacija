import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  final ConnectionSettings settings = ConnectionSettings(
    host: 'ucka.veleri.hr',
    port: 3306,
    user: 'lmajetic',
    password: '11',
    db: 'lmajetic',
  );

  Future<MySqlConnection> connect() async {
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
        'SELECT KorisnickoIme,EmailKorisnika FROM KORISNIK WHERE KorisnickoIme LIKE ?',
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

  Future<List<String>> fetchComments(int recipeId) async {
    final connection = await connect();
    try {
      final results = await connection.query(
          'SELECT SadrzajKomentara FROM Komentar WHERE SifraRecepta = ?',
          [recipeId]);
      return results.map((row) => row['SadrzajKomentara'] as String).toList();
    } finally {
      await connection.close();
    }
  }

  Future<void> addComment(int recipeId, String comment, String mail) async {
    final connection = await connect();
    try {
      await connection.query(
          'INSERT INTO Komentar (SifraRecepta, SadrzajKomentara, EmailKorisnika) VALUES (?, ?, ?)',
          [recipeId, comment, mail]);
    } finally {
      await connection.close();
    }
  }

  Future<List<Profile>> fetchProfile(String email) async {
    final connection = await connect();
    try {
      final results = await connection.query(
          'SELECT KorisnickoIme, EmailKorisnika FROM KORISNIK WHERE EmailKorisnika = ?',
          [email]);
      return results.map((row) {
        return Profile(
          mail: row['EmailKorisnika'] as String,
          username: row['KorisnickoIme'] as String,
          
        );
      }).toList();
    } finally {
      await connection.close();
    }
  }

  Future<bool> switchUser(String username, String password) async {
    final connection = await connect();
    try {
      final results = await connection.query(
        'SELECT * FROM KORISNIK WHERE KorisnickoIme = ? AND Lozinka = ?',
        [username, password],
      );
      return results.isNotEmpty;
    } finally {
      await connection.close();
    }
  }

  Future<bool> insertRecipe(
    String nazivRecepta, String opisRecepta, String oznakeRecepta, String emailKorisnika) async {
  final connection = await connect();
  try {
    final result = await connection.query(
      'INSERT INTO Recept (NazivRecepta, OpisRecepta, OznakeRecepta, EmailKorisnika) VALUES (?, ?, ?, ?)',
      [nazivRecepta, opisRecepta, oznakeRecepta, emailKorisnika],
    );
    return result.affectedRows != null && result.affectedRows! > 0;
  } catch (e) {
    print('Error inserting recipe: $e');
    return false;
  } finally {
    await connection.close();
  }
}

    Future<List<Recipe>> fetchUsersRecipes(String userEmail) async {
    final connection = await connect();
    try {
      final results = await connection.query(
        'SELECT SifraRecepta, NazivRecepta, OpisRecepta, OznakeRecepta FROM Recept WHERE EmailKorisnika = ?',
        [userEmail],
      );

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


}

class Recipe {
  final int id;
  final String name;
  final String? description;
  final String? tags;
  bool isLiked;
  List<String> comments;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.tags,
    this.isLiked = false,
    List<String>? comments,
  }) : comments = comments ?? [];
}

class User {
  final String mail;
  final String username;

  User({
    required this.mail,
    required this.username,
  });
}

class Profile {
  final String username;
  final String mail;
  
  Profile({required this.username, required this.mail});
}

class Comment {
  final int id;
  final int recipeId;
  final String text;
  final String mail;

  Comment({
    required this.id,
    required this.recipeId,
    required this.text,
    required this.mail,
  });

  factory Comment.fromRow(Map<String, dynamic> row) {
    return Comment(
      id: row['IDKomentara'] as int,
      recipeId: row['SifraRecepta'] as int,
      text: row['SadrzajKomentara'] as String,
      mail: row['EmailKorisnika'] as String,
    );
  }
}