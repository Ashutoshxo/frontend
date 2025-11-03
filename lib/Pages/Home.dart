import 'package:flutter/material.dart';
import '../Constants/api.dart';
import '../Models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<Todo> todos = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Todo> get _allTodos => todos;
  List<Todo> get _pendingTodos => todos.where((t) => !t.isDone).toList();
  List<Todo> get _completedTodos => todos.where((t) => t.isDone).toList();

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.fetchTodos();
      setState(() {
        todos = data;
        isLoading = false;
      });
    } catch (e) {
      print('💥 Exception: $e');
      setState(() => isLoading = false);
      _showErrorSnackbar('Failed to load todos');
    }
  }

  Future<void> _deleteTodo(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteTodo(id);
        _showSuccessSnackbar('Todo deleted successfully');
        fetchData();
      } catch (e) {
        print('Delete error: $e');
        _showErrorSnackbar('Failed to delete todo');
      }
    }
  }

  Future<void> _addTodo() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AddTodoDialog(),
    );

    if (result != null) {
      try {
        await ApiService.createTodo(
          title: result['title']!,
          description: result['description']!,
          dueDate: result['due_date']!,
        );
        _showSuccessSnackbar('Todo added successfully');
        fetchData();
      } catch (e) {
        print('Add error: $e');
        _showErrorSnackbar('Failed to add todo');
      }
    }
  }

  Future<void> _toggleTodoDone(int id, bool isDone, Todo todo) async {
    try {
      await ApiService.updateTodo(
        id: id,
        title: todo.title,
        description: todo.description,
        isDone: isDone,
        dueDate: todo.dueDate,
      );
      fetchData();
      _showSuccessSnackbar(isDone ? 'Marked as done ✓' : 'Marked as pending');
    } catch (e) {
      _showErrorSnackbar('Failed to update todo');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Todos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TodoSearchDelegate(todos),
              );
            },
          ),
          // Refresh Icon
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('All'),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_allTodos.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending'),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_pendingTodos.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Done'),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_completedTodos.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Card
                _buildStatsCard(),
                
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodoList(_allTodos),
                      _buildTodoList(_pendingTodos),
                      _buildTodoList(_completedTodos),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTodo,
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Stats Card Widget
  Widget _buildStatsCard() {
    final total = todos.length;
    final completed = _completedTodos.length;
    final pending = _pendingTodos.length;
    final percentage = total > 0 ? (completed / total * 100).toInt() : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Icons.list_alt),
              _buildStatItem('Pending', pending.toString(), Icons.pending_actions),
              _buildStatItem('Done', completed.toString(), Icons.check_circle),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% Completed',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTodoList(List<Todo> todoList) {
    if (todoList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No todos here!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new todo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          final todo = todoList[index];
          return TodoCard(
            todo: todo,
            onTap: () {
              // Todo detail view (implement later)
              print('Tapped: ${todo.title}');
            },
            onDelete: () => _deleteTodo(todo.id, todo.title),
            onToggleDone: (isDone) => _toggleTodoDone(todo.id, isDone, todo),
          );
        },
      ),
    );
  }
}