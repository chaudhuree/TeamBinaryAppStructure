import 'package:binary_demo_app/controllers/home_controller.dart';
import 'package:binary_demo_app/widgets/common/circle_loader.dart';
import 'package:binary_demo_app/widgets/home/add_todo_dialogue.dart';
import 'package:binary_demo_app/widgets/home/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo Home"),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Obx(() {
            if (controller.isLoading.value) {
              return CircleLoader();
            }
            return TodoList();
          }),
        ),
      ),
      floatingActionButton: _buildAddTodoButton(),
    );
  }

  FloatingActionButton _buildAddTodoButton() {
    return FloatingActionButton(
      onPressed: () {
        final titleController = TextEditingController();
        final descController = TextEditingController();

        Get.dialog(
          AddTodoDialogue(
            titleController: titleController,
            descController: descController,
            controller: controller,
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }
}

