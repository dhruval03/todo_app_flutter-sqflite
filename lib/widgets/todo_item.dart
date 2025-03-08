import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function() onTap;
  final Function(int) onDelete;

  TodoItem({required this.todo, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(decoration: todo.isDone ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(todo.description),
      onTap: onTap, // Navigate to details screen
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => onDelete(todo.id!),
      ),
    );
  }
}
