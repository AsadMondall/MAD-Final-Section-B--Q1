import 'package:get/get.dart';
import 'database_helper.dart';

class TodoController extends GetxController {
  var todos = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  void fetchTodos() async {
    isLoading(true); // Start loading
    try {
      var fetchedTodos = await DatabaseHelper.instance.queryAll();
      todos.assignAll(fetchedTodos);
    } catch (e) {
      // Handle any errors
      print("Error fetching todos: $e");
    } finally {
      isLoading(false); // Stop loading
    }
  }

  void addTodo(Map<String, dynamic> todo) async {
    await DatabaseHelper.instance.insert(todo);
    fetchTodos(); // Refresh the list after adding
  }

  void updateTodo(Map<String, dynamic> todo) async {
    await DatabaseHelper.instance.update(todo);
    fetchTodos(); // Refresh the list after updating
  }

  void deleteTodo(int id) async {
    await DatabaseHelper.instance.delete(id);
    fetchTodos(); // Refresh the list after deleting
  }

  void toggleDone(int id) async {
    var todo =
        todos.firstWhere((element) => element[DatabaseHelper.columnId] == id);
    todo[DatabaseHelper.columnIsDone] =
        todo[DatabaseHelper.columnIsDone] == 0 ? 1 : 0;
    updateTodo(todo); // Update the to-do item with the new done status
  }
}
