import 'package:flutter_test/flutter_test.dart';
import 'todo_app.dart';

void main() {
  group('TodoState', () {
    late TodoState todoState;

    setUp(() {
      todoState = TodoState();
    });

    tearDown(() {
      todoState.dispose();
    });

    test('should initialize with empty todo list and "all" filter', () {
      expect(todoState.todos.get(), isEmpty);
      expect(todoState.filterMode.get(), 'all');
    });

    test('should add new todo', () {
      todoState.addTodo('Test todo');

      final todos = todoState.todos.get();
      expect(todos.length, 1);
      expect(todos.first.text, 'Test todo');
      expect(todos.first.isCompleted, false);
    });

    test('should not add empty todo', () {
      todoState.addTodo('');
      todoState.addTodo('   ');

      expect(todoState.todos.get(), isEmpty);
    });

    test('should toggle todo completion', () {
      todoState.addTodo('Test todo');
      final todoId = todoState.todos.get().first.id;

      todoState.toggleTodo(todoId);
      expect(todoState.todos.get().first.isCompleted, true);

      todoState.toggleTodo(todoId);
      expect(todoState.todos.get().first.isCompleted, false);
    });

    test('should remove todo', () {
      todoState.addTodo('Test todo');
      final todoId = todoState.todos.get().first.id;

      todoState.removeTodo(todoId);
      expect(todoState.todos.get(), isEmpty);
    });

    test('should filter todos correctly', () {
      todoState.addTodo('Todo 1');
      todoState.addTodo('Todo 2');
      todoState.addTodo('Todo 3');

      final todos = todoState.todos.get();
      todoState.toggleTodo(todos[0].id); // Complete first todo

      todoState.setFilter('all');
      expect(todoState.getFilteredTodos().length, 3);

      todoState.setFilter('active');
      expect(todoState.getFilteredTodos().length, 2);

      todoState.setFilter('completed');
      expect(todoState.getFilteredTodos().length, 1);
    });

    test('should update filter mode', () {
      expect(todoState.filterMode.get(), 'all');

      todoState.setFilter('active');
      expect(todoState.filterMode.get(), 'active');

      todoState.setFilter('completed');
      expect(todoState.filterMode.get(), 'completed');
    });
  });
}
