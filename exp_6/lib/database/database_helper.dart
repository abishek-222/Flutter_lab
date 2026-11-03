
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/student.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static const String databaseName = 'student_database.db';
  static const String tableName = 'students';

  Database? _database;

  // Initialize and open database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await databaseFactoryFfiWeb.openDatabase(
      databaseName,
      options: OpenDatabaseOptions(
        version: 1,

        // Create students table
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE students (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              register_number TEXT NOT NULL,
              department TEXT NOT NULL,
              email TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    return _database!;
  }

  // CREATE: Insert student record
  Future<int> insertStudent(Student student) async {
    final db = await database;

    return await db.insert(
      tableName,
      student.toMap(),
    );
  }

  // READ: Retrieve all student records
  Future<List<Student>> getStudents() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query(
      tableName,
      orderBy: 'id DESC',
    );

    return maps.map((map) => Student.fromMap(map)).toList();
  }
}
