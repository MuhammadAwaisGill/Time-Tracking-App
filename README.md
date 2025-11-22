# Time Tracking App 🕐

A Flutter-based time tracking application for monitoring time spent on tasks and projects with persistent local storage.

## 📱 Features

- ✅ Track time entries with project, task, date, hours, and notes
- ✅ Create and manage projects and tasks
- ✅ View entries in two modes: All Entries & Grouped by Projects
- ✅ Persistent local storage - data never lost
- ✅ Clean Material Design UI with intuitive navigation
- ✅ Delete entries, projects, and tasks

## 🛠️ Tech Stack

- **Flutter** - Cross-platform framework
- **Provider** - State management
- **LocalStorage** - Data persistence
- **Intl** - Date formatting

## 🚀 Installation

```bash
# Clone repository
git clone https://github.com/yourusername/time_tracking_app.git
cd time_tracking_app

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome
```

## 📂 Project Structure

```
lib/
├── main.dart
├── models/           # Project, Task, TimeEntry models
├── providers/        # TimeEntryProvider for state management
└── screens/          # Home, AddEntry, Project & Task management
```

## 💡 Quick Usage

1. **Add Project** → Drawer → Projects → Tap (+) → Enter name
2. **Add Task** → Drawer → Tasks → Tap (+) → Enter name
3. **Track Time** → Home → Tap (+) → Fill form → Save
4. **View Data** → Switch between "All Entries" and "Grouped by Projects" tabs

## 🎯 Key Learning Outcomes

- Flutter widget composition and state management
- Provider pattern implementation
- Local storage integration
- Form validation and data handling
- Multi-screen navigation with drawer

## 📦 Dependencies

```yaml
provider: ^6.1.1
intl: ^0.19.0
localstorage: ^4.0.1+4
collection: ^1.18.0
```

## 🚧 Future Enhancements

- Export to CSV
- Analytics dashboard
- Start/stop timer
- Cloud sync
- Dark mode

## 👤 Author

**Muhammad Awais**

- GitHub: [@MuhammadAwaisGill](https://github.com/MuhammadAwaisGill)
- LinkedIn: [Muhammad Awais](https://www.linkedin.com/in/-muhammad--awais/)

## 📜 Certificate

Built as part of IBM's "Flutter and Dart: Developing iOS, Android, and Mobile Apps" course on Coursera.

---

**⭐ Star this repo if you found it helpful!**

*Built with Flutter & ❤️*
