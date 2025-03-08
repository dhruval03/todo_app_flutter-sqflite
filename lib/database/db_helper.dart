import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'todo.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          isDone INTEGER,
          createdAt TEXT,
          completedAt TEXT NULL,
          plannedCompletionAt TEXT NULL
        )
      ''');
      },
    );
  }

  // Insert a new todo
  Future<int> insertTodo(Todo todo) async {
    final db = await database;

    final Map<String, dynamic> todoMap = todo.toMap();

    // Ensure correct date format and handle null values
    todoMap['completedAt'] = todo.completedAt ?? ''; // Use empty string if null
    todoMap['plannedCompletionAt'] =
        todo.plannedCompletionAt ?? ''; // Avoid inserting null

    print("Inserting Task: $todoMap"); // Debugging log

    return await db.insert(
      'todos',
      todoMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all todos
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Update a todo
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return db.update(
      'todos',
      {
        ...todo.toMap(),
        'completedAt': todo.isDone ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete a todo
  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete('todos', where: "id = ?", whereArgs: [id]);
  }
}
