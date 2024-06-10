import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'todo_controller.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.black87),
          headline6: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.amber),
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

  void showTodoDialog(BuildContext context, {Map<String, dynamic>? todo}) {
    final TextEditingController titleController =
        TextEditingController(text: todo?[DatabaseHelper.columnTitle]);
    final TextEditingController subtitleController =
        TextEditingController(text: todo?[DatabaseHelper.columnSubtitle]);

    Get.dialog(AlertDialog(
      title: Text(todo == null ? "Add New Todo" : "Edit Todo"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: subtitleController,
            decoration: InputDecoration(
              labelText: 'Subtitle',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (titleController.text.isNotEmpty &&
                subtitleController.text.isNotEmpty) {
              var newTodo = {
                DatabaseHelper.columnTitle: titleController.text,
                DatabaseHelper.columnSubtitle: subtitleController.text,
                DatabaseHelper.columnIsDone:
                    todo?[DatabaseHelper.columnIsDone] ?? 0
              };
              if (todo == null) {
                todoController.addTodo(newTodo);
              } else {
                newTodo[DatabaseHelper.columnId] =
                    todo[DatabaseHelper.columnId];
                todoController.updateTodo(newTodo);
              }
              Get.back();
            }
          },
          child: Text(todo == null ? 'Add' : 'Update'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Cancel'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List', style: Theme.of(context).textTheme.headline6),
        backgroundColor: Colors.blueAccent,
      ),
      body: Obx(() {
        if (todoController.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: Colors.blueAccent));
        }
        if (todoController.todos.isEmpty) {
          return Center(child: Text('No todos available'));
        }
        return ListView.builder(
          itemCount: todoController.todos.length,
          itemBuilder: (context, index) {
            var todo = todoController.todos[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                tileColor: Colors.blue[50],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                title: Text(
                  todo[DatabaseHelper.columnTitle],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  todo[DatabaseHelper.columnSubtitle],
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: Icon(
                    todo[DatabaseHelper.columnIsDone] == 1
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: todo[DatabaseHelper.columnIsDone] == 1
                        ? Colors.green
                        : Colors.grey,
                  ),
                  onPressed: () {
                    todoController.toggleDone(todo[DatabaseHelper.columnId]);
                  },
                ),
                onTap: () {
                  showTodoDialog(context, todo: todo);
                },
                onLongPress: () {
                  todoController.deleteTodo(todo[DatabaseHelper.columnId]);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTodoDialog(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
