import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/db_helper.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Todo? todo;

  TaskDetailScreen({this.todo});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isDone = false;
  String? _plannedCompletionAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? "");
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? "",
    );
    _isDone = widget.todo?.isDone ?? false;
    _plannedCompletionAt = widget.todo?.plannedCompletionAt;
  }

  Future<void> _selectPlannedCompletionDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _plannedCompletionAt = pickedDate.toIso8601String();
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final newTodo = Todo(
        id: widget.todo?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        isDone: _isDone,
        createdAt: widget.todo?.createdAt ?? DateTime.now().toIso8601String(),
        completedAt: _isDone ? DateTime.now().toIso8601String() : null,
        plannedCompletionAt:
            _plannedCompletionAt?.isNotEmpty == true
                ? _plannedCompletionAt
                : null, // Ensure correct handling of null values
      );

      try {
        if (widget.todo == null) {
          await _dbHelper.insertTodo(newTodo);
        } else {
          await _dbHelper.updateTodo(newTodo);
        }
        Navigator.pop(context, true);
      } catch (e) {
        print("Error inserting task: $e"); // Debugging log
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? "New Task" : "Edit Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
                validator:
                    (value) => value!.isEmpty ? "Title cannot be empty" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Completed"),
                  Switch(
                    value: _isDone,
                    onChanged: (value) {
                      setState(() {
                        _isDone = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Planned Completion: "),
                  Text(
                    _plannedCompletionAt != null
                        ? DateFormat.yMd().format(
                          DateTime.parse(_plannedCompletionAt!),
                        )
                        : "Not Set",
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectPlannedCompletionDate(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveTask, child: Text("Save Task")),
            ],
          ),
        ),
      ),
    );
  }
}
