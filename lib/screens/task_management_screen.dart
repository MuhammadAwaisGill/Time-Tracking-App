import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:time_tracking_app/models/task_model.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet!\nTap + to add a task.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return ListTile(
                title: Text(task.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteTask(task.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Task',
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final provider = Provider.of<TimeEntryProvider>(context, listen: false);

    if (provider.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a project first!')),
      );
      return;
    }

    String? selectedProjectId = provider.projects.first.id;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Task Name',
                  border: UnderlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  provider.addTask(
                    Task(
                      id: DateTime.now().toString(),
                      name: controller.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}