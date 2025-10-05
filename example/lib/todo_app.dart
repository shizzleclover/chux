import 'package:flutter/material.dart';
import 'package:chux/chux.dart';

// Todo item model
class Todo {
  final String id;
  final String text;
  bool isCompleted;

  Todo({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  Todo copyWith({String? text, bool? isCompleted}) {
    return Todo(
      id: id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Todo list state management
class TodoState {
  final Chunk<List<Todo>> todos;
  final Chunk<String> filterMode; // 'all', 'active', 'completed'

  TodoState()
      : todos = Chunk<List<Todo>>([]),
        filterMode = Chunk<String>('all');

  void addTodo(String text) {
    if (text.trim().isEmpty) return;
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
    );
    todos.update((current) => [...current, newTodo]);
  }

  void toggleTodo(String id) {
    todos.update((current) {
      return current.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList();
    });
  }

  void removeTodo(String id) {
    todos.update((current) => current.where((todo) => todo.id != id).toList());
  }

  void setFilter(String mode) {
    filterMode.set(mode);
  }

  List<Todo> getFilteredTodos() {
    final allTodos = todos.get();
    switch (filterMode.get()) {
      case 'active':
        return allTodos.where((todo) => !todo.isCompleted).toList();
      case 'completed':
        return allTodos.where((todo) => todo.isCompleted).toList();
      default:
        return allTodos;
    }
  }

  void dispose() {
    todos.destroy();
    filterMode.destroy();
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chux Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _todoState = TodoState();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _todoState.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chux Todo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new todo...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      _todoState.addTodo(text);
                      _textController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _todoState.addTodo(_textController.text);
                    _textController.clear();
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text('All'),
                  onSelected: (_) => _todoState.setFilter('all'),
                  selected: _todoState.filterMode.get() == 'all',
                ),
                FilterChip(
                  label: const Text('Active'),
                  onSelected: (_) => _todoState.setFilter('active'),
                  selected: _todoState.filterMode.get() == 'active',
                ),
                FilterChip(
                  label: const Text('Completed'),
                  onSelected: (_) => _todoState.setFilter('completed'),
                  selected: _todoState.filterMode.get() == 'completed',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ChuxBuilder<String>(
              chunk: _todoState.filterMode,
              builder: (context, filterMode) {
                return ChuxBuilder<List<Todo>>(
                  chunk: _todoState.todos,
                  builder: (context, todos) {
                    final filteredTodos = _todoState.getFilteredTodos();
                    return ListView.builder(
                      itemCount: filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = filteredTodos[index];
                        return ListTile(
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (_) => _todoState.toggleTodo(todo.id),
                          ),
                          title: Text(
                            todo.text,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _todoState.removeTodo(todo.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
