import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TodoListScreen(),
    );
  }
}

// Models
class TodoItem {
  final String id;
  final String title;
  bool isCompleted;

  TodoItem({required this.id, required this.title, this.isCompleted = false});
}

// Repository with error simulation
class TodoRepository {
  List<TodoItem> _todos = [];
  bool _shouldError = false;

  Future<List<TodoItem>> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_shouldError) {
      throw Exception('Failed to load todos');
    }
    return _todos;
  }

  Future<void> addTodo(String title) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_shouldError) {
      throw Exception('Failed to add todo');
    }
    if (title.isEmpty) {
      throw Exception('Title cannot be empty');
    }
    _todos.add(TodoItem(id: DateTime.now().toString(), title: title));
  }

  Future<void> deleteTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _todos.removeWhere((todo) => todo.id == id);
  }

  void setError(bool shouldError) {
    _shouldError = shouldError;
  }

  void clear() {
    _todos.clear();
    _shouldError = false;
  }

  // For testing
  static final TodoRepository _instance = TodoRepository._();

  factory TodoRepository() {
    return _instance;
  }

  TodoRepository._();
}

// Screens
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  late Future<List<TodoItem>> _todosFuture;
  final TextEditingController _textController = TextEditingController();
  final TodoRepository _repository = TodoRepository();

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  void _refreshTodos() {
    setState(() {
      _todosFuture = _repository.getTodos();
    });
  }

  // Public method for testing
  void refreshTodos() {
    _refreshTodos();
  }

  void _addTodo() async {
    try {
      await _repository.addTodo(_textController.text);
      _textController.clear();
      _refreshTodos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            key: Key('success_snackbar'),
            content: Text('Todo added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const Key('error_snackbar'),
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('todo_input_field'),
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter todo title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  key: const Key('add_todo_button'),
                  onPressed: _addTodo,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TodoItem>>(
              future: _todosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      key: Key('loading_indicator'),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      key: const Key('error_text'),
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final todos = snapshot.data ?? [];

                if (todos.isEmpty) {
                  return const Center(
                    child: Text(
                      key: Key('empty_state_text'),
                      'No todos yet. Add one to get started!',
                    ),
                  );
                }

                return ListView.builder(
                  key: const Key('todos_list'),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return TodoTile(
                      key: Key('todo_tile_${todo.id}'),
                      todo: todo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoDetailScreen(todo: todo),
                          ),
                        );
                      },
                      onDelete: () async {
                        await _repository.deleteTodo(todo.id);
                        _refreshTodos();
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

class TodoTile extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      onTap: onTap,
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}

class TodoDetailScreen extends StatelessWidget {
  final TodoItem todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              key: const Key('detail_title'),
              todo.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'ID',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              key: const Key('detail_id'),
              todo.id,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
