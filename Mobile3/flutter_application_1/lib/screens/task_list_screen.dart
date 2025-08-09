import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../widgets/task_item.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Task>> _futureTasks = Future.value([]);
  List<Task> _cachedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _apiService.getTasks();
      setState(() {
        _cachedTasks = List.from(tasks);
        _futureTasks = Future.value(tasks);
      });
    } catch (e) {
      _showErrorSnackbar('Error al cargar tareas: ${e.toString()}');
      setState(() {
        _futureTasks = Future.value(_cachedTasks);
      });
    }
  }

  Future<void> _refreshTasks() async {
    await _loadTasks();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _confirmDelete(Task task) async {
    try {
      await _apiService.deleteTask(task.id!);
      _showSuccessMessage('Tarea eliminada correctamente');
      await _refreshTasks();
    } catch (e) {
      _showErrorSnackbar('Error al eliminar: ${e.toString()}');
    }
  }

  Future<void> _navigateToFormScreen(BuildContext context, [Task? task]) async {
    final result = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );

    if (result == null && task != null) {

      await _confirmDelete(task);
    } 
    else if (result != null) {

      try {
        if (result.id == null) {
          await _apiService.createTask(result);
          _showSuccessMessage('Tarea creada correctamente');
        } else {
          await _apiService.updateTask(result);
          _showSuccessMessage('Tarea actualizada correctamente');
        }
        await _refreshTasks();
      } catch (e) {
        _showErrorSnackbar('Error al guardar: ${e.toString()}');
      }
    }
  }

  Future<void> _handleToggle(Task task, int index, List<Task> tasks) async {
    try {
      final newValue = !task.completed;
      final updatedTask = task.copyWith(completed: newValue);

      setState(() {
        tasks[index] = updatedTask;
      });

      await _apiService.updateTask(updatedTask);
      await _refreshTasks();
    } catch (e) {

      setState(() {
        tasks[index] = task.copyWith(completed: !task.completed);
      });
      _showErrorSnackbar('Error al actualizar: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
            tooltip: 'Recargar tareas',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: FutureBuilder<List<Task>>(
          future: _futureTasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final tasks = snapshot.data ?? [];
            if (tasks.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskItem(
                  key: ValueKey('${task.id}_${task.title}'),
                  task: task,
                  onToggle: (bool? newValue) => _handleToggle(task, index, tasks),
                  onTap: () => _navigateToFormScreen(context, task),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToFormScreen(context),
        child: const Icon(Icons.add),
        tooltip: 'Agregar nueva tarea',
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar tareas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshTasks,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay tareas disponibles',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Presiona el botón + para agregar una nueva'),
        ],
      ),
    );
  }
}