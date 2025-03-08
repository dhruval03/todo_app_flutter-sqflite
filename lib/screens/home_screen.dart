import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/db_helper.dart';
import '../widgets/todo_item.dart';
import 'task_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    final todos = await _dbHelper.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  void _openTaskDetails(Todo? todo) async {
    bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(todo: todo)),
    );

    if (isUpdated == true) {
      _loadTodos(); // Refresh list after returning
    }
  }

  void _deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    _loadTodos();
  }

  // Format timestamps for readability
  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todo App")),
      body:
          _todos.isEmpty
              ? Center(child: Text("No tasks available"))
              : ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  Todo todo = _todos[index];

                  return ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            todo.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(todo.description),
                        Text(
                          "Created: ${DateTime.parse(todo.createdAt).toLocal()}",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (todo.plannedCompletionAt != null)
                          Text(
                            "Planned Completion: ${DateFormat.yMd().format(DateTime.parse(todo.plannedCompletionAt!))}",
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        if (todo.completedAt != null)
                          Text(
                            "Completed: ${DateFormat.yMd().format(DateTime.parse(todo.completedAt!))}",
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                      ],
                    ),
                    onTap:
                        () =>
                            _openTaskDetails(todo), // Open task details screen
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTodo(todo.id!),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskDetails(null), // Create new task
        child: Icon(Icons.add),
      ),
    );
  }
}
