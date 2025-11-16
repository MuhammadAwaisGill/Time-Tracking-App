import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/models/timeentry_model.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:intl/intl.dart';

class AddTimeEntryScreen extends StatefulWidget {
  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Entry'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Please add projects and tasks first from the menu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
            );
          }

          // Set default values if not set
          projectId ??= provider.projects.first.id;
          final availableTasks = provider.tasks.where((t) => t.id == projectId).toList();
          if (availableTasks.isNotEmpty && taskId == null) {
            taskId = availableTasks.first.id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: projectId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        projectId = newValue;
                        taskId = null; // Reset task when project changes
                      });
                    },
                    items: provider.projects.map<DropdownMenuItem<String>>((project) {
                      return DropdownMenuItem<String>(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: taskId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        taskId = newValue;
                      });
                    },
                    items: availableTasks.map<DropdownMenuItem<String>>((task) {
                      return DropdownMenuItem<String>(
                        value: task.id,
                        child: Text(task.name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Date: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy-MM-dd').format(date),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != date) {
                        setState(() {
                          date = picked;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Total Time (in hours)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter total time';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => totalTime = double.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (value) => notes = value ?? '',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (taskId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please add a task for this project first!')),
                            );
                            return;
                          }
                          _formKey.currentState!.save();
                          Provider.of<TimeEntryProvider>(context, listen: false).addTimeEntry(
                            TimeEntry(
                              id: DateTime.now().toString(),
                              projectId: projectId!,
                              taskId: taskId!,
                              totalTime: totalTime,
                              date: date,
                              notes: notes,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save Entry', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}