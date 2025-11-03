class Todo {
  final int id;
  final String title;
  final String description;
  final bool isDone;
  final String dueDate;
  final String createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.dueDate,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isDone: json['is_done'] ?? false,
      dueDate: json['due_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}