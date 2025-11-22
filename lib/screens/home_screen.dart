import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/models/project_model.dart';
import 'package:time_tracking_app/models/task_model.dart';
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
            Tab(text: 'By Projects'),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.access_time, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Time Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your time',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.teal),
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
              leading: const Icon(Icons.assignment, color: Colors.teal),
              title: const Text('Tasks', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TaskManagementScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('About', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Time Tracker',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.access_time, size: 40, color: Colors.teal),
                  children: const [
                    Text('A simple time tracking app built with Flutter.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllEntriesTab(provider),
              _buildGroupedByProjectsTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTimeEntryScreen()),
          );
        },
        backgroundColor: Colors.amber,
        tooltip: 'Add Time Entry',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAllEntriesTab(TimeEntryProvider provider) {
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

    // Sort entries by date (newest first)
    final sortedEntries = List.from(provider.entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final project = provider.projects.firstWhere(
              (p) => p.id == entry.projectId,
          orElse: () => Project(id: '', name: 'Unknown Project'),
        );
        final task = provider.tasks.firstWhere(
              (t) => t.id == entry.taskId,
          orElse: () => Task(id: '', name: 'Unknown Task'),
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                '${entry.totalTime.toStringAsFixed(1)}h',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(
              '${project.name} - ${task.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(DateFormat('yyyy-MM-dd').format(entry.date)),
                  ],
                ),
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.notes, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text('Are you sure you want to delete this time entry?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.deleteTimeEntry(entry.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Entry deleted')),
                          );
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedByProjectsTab(TimeEntryProvider provider) {
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
        orElse: () => Project(id: '', name: 'Unknown Project'),
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
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                totalHours.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(
              projectName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('${entries.length} entries • Total: ${totalHours.toStringAsFixed(1)} hours'),
            children: entries.map<Widget>((entry) {
              final task = provider.tasks.firstWhere(
                    (t) => t.id == entry.taskId,
                orElse: () => Task(id: '', name: 'Unknown Task'),
              );

              return ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                title: Text(task.name),
                subtitle: Text(
                  '${DateFormat('yyyy-MM-dd').format(entry.date)} - ${entry.totalTime} hours',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Entry'),
                        content: const Text('Are you sure you want to delete this time entry?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteTimeEntry(entry.id);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Entry deleted')),
                              );
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}