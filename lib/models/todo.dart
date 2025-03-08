class Todo {
  int? id;
  String title;
  String description;
  bool isDone;
  String createdAt; // Task creation timestamp
  String? completedAt; // Actual completion timestamp
  String? plannedCompletionAt; // Planned completion timestamp

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    String? createdAt,
    this.completedAt,
    this.plannedCompletionAt,
  }) : createdAt =
           createdAt ?? DateTime.now().toIso8601String(); // Default to now

  factory Todo.fromMap(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'] == 1,
      createdAt: json['createdAt'],
      completedAt:
          (json['completedAt'] != null && json['completedAt'].isNotEmpty)
              ? json['completedAt']
              : null,
      plannedCompletionAt:
          (json['plannedCompletionAt'] != null &&
                  json['plannedCompletionAt'].isNotEmpty)
              ? json['plannedCompletionAt']
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt, // Should be in ISO-8601 format
      'completedAt': completedAt, // Store null instead of empty string
      'plannedCompletionAt':
          plannedCompletionAt, // Store null instead of empty string
    };
  }
}
