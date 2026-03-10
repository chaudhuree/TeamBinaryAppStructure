import 'package:binary_demo_app/controllers/home_controller.dart';
import 'package:binary_demo_app/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return ListView.builder(
      itemCount: controller.todoList.length,
      itemBuilder: (context, index) {
        TodoModel todo = controller.todoList[index];
        return ListTile(
          trailing: GestureDetector(
            onTap: () {
              controller.removeTodo(todo);
            },
            child: Icon(Icons.delete_forever, color: Colors.red),
          ),
          title: Text(todo.title),
          subtitle: Text(todo.description),
        );
      },
    );
  }
}
