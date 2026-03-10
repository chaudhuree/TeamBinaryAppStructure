import 'package:binary_demo_app/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList<TodoModel> todoList = <TodoModel>[].obs;

  final List<TodoModel> _initialTodoList = [
    TodoModel(title: "Todo 1", description: "Todo Description 1"),
    TodoModel(title: "Todo 2", description: "Todo Description 2"),
    TodoModel(title: "Todo 3", description: "Todo Description 3"),
  ];

  RxBool isLoading = false.obs;

  Future<void> initializeTodoList() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 3));
      todoList.addAll(_initialTodoList);
    } catch (e) {
      debugPrint("Load Todo Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTodo(TodoModel todo) async{
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 3));
      todoList.add(todo);
    } catch (e) {
      debugPrint("Add Todo Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeTodo(TodoModel todo) async{
    isLoading.value = true;
    try{
      await Future.delayed(Duration(seconds: 3));
      todoList.remove(todo);
    } catch(e){
      debugPrint("Remove Todo Error: $e");
    } finally{
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeTodoList();
  }
}
