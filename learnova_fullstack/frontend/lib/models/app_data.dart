class Course {
  String name;
  String instructor;
  String semester;
  String description;
  double progress;
  bool archived;
  Course({required this.name, required this.instructor, required this.semester, required this.description, required this.progress, this.archived = false});
}

class TaskItem {
  String title;
  String course;
  String dueDate;
  String priority;
  String description;
  bool completed;
  TaskItem({required this.title, required this.course, required this.dueDate, required this.priority, required this.description, this.completed = false});
}

class StudySession {
  String subject;
  String time;
  String duration;
  String reminder;
  StudySession({required this.subject, required this.time, required this.duration, required this.reminder});
}

class ProgressEntry {
  String task;
  String score;
  String status;
  ProgressEntry({required this.task, required this.score, required this.status});
}

class AppData {
  static List<Course> courses = [
    Course(name: 'Mobile App Development', instructor: 'Ms. Perera', semester: 'Year 2 - Semester 2', description: 'Flutter UI, state management and app navigation.', progress: 0.72),
    Course(name: 'Database Systems', instructor: 'Mr. Silva', semester: 'Year 2 - Semester 2', description: 'ER diagrams, SQL and data management.', progress: 0.58),
    Course(name: 'Software Engineering', instructor: 'Dr. Fernando', semester: 'Year 2 - Semester 2', description: 'Planning, requirements and project documentation.', progress: 0.84),
  ];

  static List<TaskItem> tasks = [
    TaskItem(title: 'Submit UI wireframes', course: 'Mobile App Development', dueDate: 'Today, 6.00 PM', priority: 'High', description: 'Finalize Learnova mobile screens and export PDF.'),
    TaskItem(title: 'Database quiz revision', course: 'Database Systems', dueDate: 'Tomorrow', priority: 'Medium', description: 'Revise normalization and SQL joins.'),
    TaskItem(title: 'Project report update', course: 'Software Engineering', dueDate: 'Friday', priority: 'High', description: 'Update objectives and implementation screenshots.'),
  ];

  static List<StudySession> sessions = [
    StudySession(subject: 'Flutter forms', time: '8.00 AM', duration: '1 hour', reminder: '15 minutes before'),
    StudySession(subject: 'Database SQL', time: '4.00 PM', duration: '45 minutes', reminder: '10 minutes before'),
  ];

  static List<ProgressEntry> progress = [
    ProgressEntry(task: 'UI Design', score: '85%', status: 'Completed'),
    ProgressEntry(task: 'Login Flow', score: '70%', status: 'In Progress'),
    ProgressEntry(task: 'Task Module', score: '65%', status: 'In Progress'),
  ];

  static String studentName = 'Sandali Wijerathna';
  static String email = 'student@learnova.lk';
  static String course = 'BSc Undergraduate';
  static String goal = 'Complete all assignments before deadlines and maintain high academic performance.';
}
