import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:time_tracking_app/screens/time_entry_screen.dart';
import 'package:time_tracking_app/screens/project_management_screen.dart';
import 'package:time_tracking_app/screens/task_management_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Entries'),
            Tab(text: 'Grouped by Projects'),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: Colors.teal,
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.black87),
              title: const Text('Projects', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProjectManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.black87),
              title: const Text('Tasks', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TaskManagementScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllEntriesTab(),
          _buildGroupedByProjectsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Time Entry',
      ),
    );
  }

  Widget _buildAllEntriesTab() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No time entries yet!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first entry.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: provider.entries.length,
          itemBuilder: (context, index) {
            final entry = provider.entries[index];
            final project = provider.projects.firstWhere(
                  (p) => p.id == entry.projectId,
              orElse: () => provider.projects.first,
            );
            final task = provider.tasks.firstWhere(
                  (t) => t.id == entry.taskId,
              orElse: () => provider.tasks.first,
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text(
                  '${project.name} - ${task.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Date: ${DateFormat('yyyy-MM-dd').format(entry.date)}'),
                    Text('Time: ${entry.totalTime} hours'),
                    if (entry.notes.isNotEmpty) Text('Notes: ${entry.notes}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteTimeEntry(entry.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupedByProjectsTab() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No time entries yet!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first entry.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        Map<String, List<dynamic>> groupedEntries = {};
        for (var entry in provider.entries) {
          final project = provider.projects.firstWhere(
                (p) => p.id == entry.projectId,
            orElse: () => provider.projects.first,
          );
          if (!groupedEntries.containsKey(project.name)) {
            groupedEntries[project.name] = [];
          }
          groupedEntries[project.name]!.add(entry);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: groupedEntries.length,
          itemBuilder: (context, index) {
            final projectName = groupedEntries.keys.elementAt(index);
            final entries = groupedEntries[projectName]!;
            final totalHours = entries.fold<double>(
              0,
                  (sum, entry) => sum + entry.totalTime,
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ExpansionTile(
                title: Text(
                  projectName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Total: ${totalHours.toStringAsFixed(1)} hours'),
                children: entries.map<Widget>((entry) {
                  final task = provider.tasks.firstWhere(
                        (t) => t.id == entry.taskId,
                    orElse: () => provider.tasks.first,
                  );
                  return ListTile(
                    title: Text(task.name),
                    subtitle: Text(
                      '${DateFormat('yyyy-MM-dd').format(entry.date)} - ${entry.totalTime} hours',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        provider.deleteTimeEntry(entry.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}