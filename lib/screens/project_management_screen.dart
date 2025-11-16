import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:time_tracking_app/models/project_model.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            return const Center(
              child: Text(
                'No projects yet!\nTap + to add a project.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return ListTile(
                title: Text(project.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteProject(project.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Project',
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Project'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Project Name',
              border: UnderlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final provider = Provider.of<TimeEntryProvider>(context, listen: false);
                  provider.addProject(
                    Project(
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