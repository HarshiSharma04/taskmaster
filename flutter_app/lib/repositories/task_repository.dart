import 'package:dio/dio.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskException implements Exception {
  final String message;
  final int? statusCode;
  const TaskException(this.message, {this.statusCode});
}

class TasksResult {
  final List<TaskModel> tasks;
  final PaginationInfo pagination;

  const TasksResult({required this.tasks, required this.pagination});
}

class TaskRepository {
  final ApiService _api;

  TaskRepository(this._api);

  Future<TasksResult> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? priority,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final data = await _api.getTasks(
        page: page,
        limit: limit,
        status: status,
        priority: priority,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final tasks = (data['tasks'] as List<dynamic>)
          .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
          .toList();
      final pagination = PaginationInfo.fromJson(
          data['pagination'] as Map<String, dynamic>);

      return TasksResult(tasks: tasks, pagination: pagination);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TaskModel> getTask(String id) async {
    try {
      final data = await _api.getTaskById(id);
      return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    try {
      final data = await _api.createTask(
        title: title,
        description: description,
        status: status?.value,
        priority: priority?.value,
        dueDate: dueDate?.toIso8601String(),
        tags: tags,
      );
      return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TaskModel> updateTask(
    String id, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    try {
      final data = await _api.updateTask(
        id,
        title: title,
        description: description,
        status: status?.value,
        priority: priority?.value,
        dueDate: dueDate?.toIso8601String(),
        tags: tags,
      );
      return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _api.deleteTask(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TaskModel> toggleTask(String id) async {
    try {
      final data = await _api.toggleTask(id);
      return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TaskStats> getStats() async {
    try {
      final data = await _api.getTaskStats();
      return TaskStats.fromJson(data['stats'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  TaskException _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message =
        (e.response?.data as Map<String, dynamic>?)?['message'] as String?;

    return TaskException(
      message ?? _defaultMessage(statusCode),
      statusCode: statusCode,
    );
  }

  String _defaultMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid data provided.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to do this.';
      case 404:
        return 'Task not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
