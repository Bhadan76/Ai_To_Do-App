class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String dueDate;
  final String dueTime;
  final String reminder;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Work',
    this.priority = 'Normal',
    this.dueDate = '',
    this.dueTime = '',
    this.reminder = 'On Time',
    this.isCompleted = false,
  });
}

class MockTasks {
  static List<TaskModel> tasks = [
    TaskModel(
      id: '1',
      title: 'Design new UI',
      description: 'Create a modern and beautiful UI for the todo app.',
      category: 'Work',
      priority: 'High Priority',
      dueDate: 'Today',
      dueTime: '9:00 AM',
      reminder: 'On Time',
      isCompleted: true,
    ),
    TaskModel(
      id: '2',
      title: 'Read documentation',
      description: 'Read Flutter GetX documentation.',
      category: 'Study',
      priority: 'Normal',
      dueDate: 'Today',
      dueTime: '7:00 PM',
      reminder: 'On Time',
      isCompleted: false,
    ),
    TaskModel(
      id: '3',
      title: 'Buy groceries',
      description: 'Buy milk, eggs, and bread.',
      category: 'Personal',
      priority: 'Normal',
      dueDate: 'Today',
      dueTime: '8:00 PM',
      reminder: 'On Time',
      isCompleted: false,
    ),
    TaskModel(
      id: '4',
      title: 'Morning workout',
      description: '30 minute cardio session.',
      category: 'Health',
      priority: 'Normal',
      dueDate: 'Tomorrow',
      dueTime: '7:00 AM',
      reminder: 'On Time',
      isCompleted: false,
    ),
  ];
}
