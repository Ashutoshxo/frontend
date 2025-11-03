import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/todo.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  
  static Future<List<Todo>> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((item) => Todo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }


  static Future<Todo> createTodo({
    required String title,
    required String description,
    required String dueDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'title': title,
          'description': description,
          'due_date': dueDate,
          'is_done': false,
        }),
      );

      if (response.statusCode == 201) {
        return Todo.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating todo: $e');
    }
  }

 
  static Future<void> deleteTodo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }


  static Future<Todo> updateTodo({
    required int id,
    required String title,
    required String description,
    required bool isDone,
    required String dueDate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'title': title,
          'description': description,
          'is_done': isDone,
          'due_date': dueDate,
        }),
      );

      if (response.statusCode == 200) {
        return Todo.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update todo');
      }
    } catch (e) {
      throw Exception('Error updating todo: $e');
    }
  }
}
