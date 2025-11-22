import 'package:flutter/material.dart';
import 'package:time_tracking_app/models/timeentry_model.dart';
import 'package:time_tracking_app/models/project_model.dart';
import 'package:time_tracking_app/models/task_model.dart';

class TimeEntryProvider with ChangeNotifier {
  List<TimeEntry> _entries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  // Time Entry methods
  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  // Project methods
  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void deleteProject(String id) {
    // Delete related tasks and entries
    _tasks.removeWhere((task) => task.id.startsWith(id));
    _entries.removeWhere((entry) => entry.projectId == id);
    _projects.removeWhere((project) => project.id == id);
    notifyListeners();
  }

  // Task methods
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    // Delete related entries
    _entries.removeWhere((entry) => entry.taskId == id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}