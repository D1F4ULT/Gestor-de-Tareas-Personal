import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((task) => Task.fromJson(task))
            .toList();
      } else {
        throw Exception(
          'Error al cargar tareas. Código: ${response.statusCode}\n'
          'Respuesta: ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error al crear tarea. Código: ${response.statusCode}\n'
          'Respuesta: ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Error al actualizar tarea. Código: ${response.statusCode}\n'
          'Respuesta: ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

Future<void> deleteTask(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar tarea. Código: ${response.statusCode}\n'
        'Respuesta: ${response.body}'
      );
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}
}