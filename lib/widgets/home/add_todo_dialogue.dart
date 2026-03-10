import 'package:binary_demo_app/controllers/home_controller.dart';
import 'package:binary_demo_app/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTodoDialogue extends StatelessWidget {
  const AddTodoDialogue({
    super.key,
    required this.titleController,
    required this.descController,
    required this.controller,
  });

  final TextEditingController titleController;
  final TextEditingController descController;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Todo"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: descController,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            String title = titleController.text;
            String desc = descController.text;

            controller.addTodo(TodoModel( title: title, description: desc));

            Get.back();
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}
