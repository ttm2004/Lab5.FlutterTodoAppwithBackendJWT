import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/api_service.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoModel> _todos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TodoModel> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TodoModel> get completedTodos =>
      _todos.where((t) => t.isCompleted).toList();
  List<TodoModel> get pendingTodos =>
      _todos.where((t) => !t.isCompleted).toList();

  // ─── Fetch all todos ───────────────────────────────────────────────────────

  Future<void> fetchTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService.getTodos();
      _todos = data.map((e) => TodoModel.fromJson(e)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách todo';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Create ────────────────────────────────────────────────────────────────

  Future<bool> createTodo(String title, String description) async {
    _errorMessage = null;
    try {
      final data =
          await ApiService.createTodo(title: title, description: description);
      final newTodo = TodoModel.fromJson(data['todo'] ?? data);
      _todos.insert(0, newTodo);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Không thể tạo todo';
      notifyListeners();
      return false;
    }
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<bool> updateTodo(
      int id, String title, String description, bool isCompleted) async {
    _errorMessage = null;
    try {
      final data = await ApiService.updateTodo(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
      );
      final updated = TodoModel.fromJson(data['todo'] ?? data);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật todo';
      notifyListeners();
      return false;
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<bool> deleteTodo(int id) async {
    _errorMessage = null;
    try {
      await ApiService.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Không thể xoá todo';
      notifyListeners();
      return false;
    }
  }

  // ─── Toggle complete ───────────────────────────────────────────────────────

  Future<bool> toggleTodo(int id) async {
    _errorMessage = null;
    try {
      final data = await ApiService.toggleTodo(id);
      final updated = TodoModel.fromJson(data['todo'] ?? data);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật trạng thái';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearTodos() {
    _todos = [];
    notifyListeners();
  }
}
