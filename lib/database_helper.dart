import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root', // Update with your database username
      password: '', // Update with your database password
      db: 'system', // Update with your database name
    );
    return await MySqlConnection.connect(settings);
  }

  static Future<void> closeConnection(MySqlConnection connection) async {
    await connection.close();
  }
}
