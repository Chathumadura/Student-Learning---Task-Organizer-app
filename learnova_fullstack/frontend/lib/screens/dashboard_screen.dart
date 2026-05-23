import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';
import 'dart:async';
import '../services/task_event_bus.dart';
import '../services/course_event_bus.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> dashboardFuture;
  late Future<Map<String, dynamic>> profileFuture;
  StreamSubscription<void>? _taskSub;
  StreamSubscription<void>? _courseSub;

  @override
  void initState() {
    super.initState();
    dashboardFuture = _loadDashboard();
    profileFuture = ApiService.profile();
    // Subscribe to task changes for auto-refresh
    _taskSub = TaskEventBus.stream.listen((_) {
      if (mounted) {
        setState(() {
          dashboardFuture = _loadDashboard();
        });
      }
    });
    // Subscribe to course changes for auto-refresh
    _courseSub = CourseEventBus.stream.listen((_) {
      if (mounted) {
        setState(() {
          dashboardFuture = _loadDashboard();
        });
      }
    });
  }

  Future<List<dynamic>> _loadDashboard() async {
    final results = await Future.wait([
      ApiService.dashboard(),
      ApiService.tasks(),
    ]);
    return results;
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    _courseSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
        future: dashboardFuture,
        builder: (context, snap) {
          final data = snap.data ?? [];
          final d = data.isNotEmpty ? (data[0] as Map<String, dynamic>) : {};
          final List tasks = data.length > 1 ? (data[1] as List<dynamic>) : [];
          final name = safe(d['student_name'], 'Student');
          final todayTasks = _tasksForToday(tasks).length;
          final upNextTasks = _upNextTasks(tasks);

          return LScaffold(
            bottomNav: true,
            currentIndex: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/profile')
                            .then((_) => setState(() {
                              dashboardFuture = _loadDashboard();
                              profileFuture = ApiService.profile();
                            })),
                        borderRadius: BorderRadius.circular(28),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: profileFuture,
                          builder: (context, profileSnap) {
                            final profileData = profileSnap.data ?? {};
                            final profilePic =
                                profileData['profile_picture'];
                            
                            if (profilePic != null &&
                                profilePic.toString().isNotEmpty) {
                              try {
                                return CircleAvatar(
                                  radius: 24,
                                  backgroundImage: MemoryImage(
                                    base64Decode(profilePic),
                                  ),
                                );
                              } catch (_) {
                                return _buildInitialsAvatar(name);
                              }
                            }
                            return _buildInitialsAvatar(name);
                          },
                        ),
                      ),
                    )
                  ],
                ),

                Text(
                  'Hi ${name.split(' ').first} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Let’s be productive today!',
                  style: TextStyle(color: AppColors.muted),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        Icons.check_circle_outline,
                        'Today’s Tasks',
                          todayTasks.toString(),
                        AppColors.blue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _miniStat(
                        Icons.warning_amber_rounded,
                        'Deadlines',
                        safe(d['deadlines'], '0'),
                        AppColors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                LCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Study Hours',
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              text: safe(d['total_study_hours'], '4.5'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                              children: const [
                                TextSpan(
                                  text: '  hrs',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.muted,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _action(
                        context,
                        Icons.add,
                        'Add Task',
                        '/addTask',
                        const Color(0xFFF3E8FF),
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _action(
                        context,
                        Icons.menu_book_outlined,
                        'Add Course',
                        '/addCourse',
                        const Color(0xFFFFEDD5),
                        AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _action(
                        context,
                        Icons.calendar_month,
                        'Planner',
                        '/planner',
                        const Color(0xFFDCFCE7),
                        AppColors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Up Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/tasks'),
                      child: const Text('View All'),
                    ),
                  ],
                ),

                upNextTasks.isEmpty
                    ? LCard(
                        child: Column(
                          children: const [
                            Icon(
                              Icons.task_alt,
                              size: 42,
                              color: AppColors.muted,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No tasks added yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add a new task to see it here.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LCard(
                        child: Column(
                          children: List.generate(upNextTasks.length, (index) {
                            final task = upNextTasks[index];

                            final title = safe(
                              task['title'] ?? task['task_title'] ?? task['name'],
                              'Untitled Task',
                            );

                            final course = safe(
                              task['course'] ??
                                  task['course_name'] ??
                                  task['subject'],
                              'Task',
                            );

                            final due = safe(
                              task['due_date'] ??
                                  task['deadline'] ??
                                  task['due'],
                              'No deadline',
                            );

                            return Column(
                              children: [
                                _upNext(
                                  Icons.menu_book_outlined,
                                  title,
                                  '$course • $due',
                                  _taskColor(due),
                                ),
                                if (index != upNextTasks.length - 1)
                                  const Divider(),
                              ],
                            );
                          }),
                        ),
                      ),
              ],
            ),
          );
        },
      );

  Widget _buildInitialsAvatar(String name) {
    String initials;
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else {
      initials = name.isEmpty ? 'CP' : name.substring(0, 1).toUpperCase();
    }
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFFDCEBFF),
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.blue,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _upNextTasks(List<dynamic> tasks) {
    final pending = tasks
        .whereType<Map>()
        .map((task) => Map<String, dynamic>.from(task))
        .where((task) => task['completed'] != true)
        .toList();

    pending.sort((a, b) {
      final aDate = _taskDate(a['due_date']);
      final bDate = _taskDate(b['due_date']);
      if (aDate == null && bDate == null) return a['id'].compareTo(b['id']);
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      final cmp = aDate.compareTo(bDate);
      if (cmp != 0) return cmp;
      return a['id'].compareTo(b['id']);
    });

    return pending.take(5).toList();
  }

  List<Map<String, dynamic>> _tasksForToday(List<dynamic> tasks) {
    final today = DateTime.now();
    return tasks
        .whereType<Map>()
        .map((task) => Map<String, dynamic>.from(task))
        .where((task) {
          if (task['completed'] == true) return false;
          final due = _taskDate(task['due_date']);
          return due != null &&
              due.year == today.year &&
              due.month == today.month &&
              due.day == today.day;
        })
        .toList();
  }

  DateTime? _taskDate(dynamic value) {
    final text = safe(value, '').trim();
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();
    if (lower == 'today') return DateTime.now();
    if (lower == 'tomorrow') {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }

    final formats = [
      RegExp(r'^(\d{4})-(\d{2})-(\d{2})$'),
      RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$'),
      RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$'),
    ];

    for (final format in formats) {
      final match = format.firstMatch(text);
      if (match == null) continue;
      try {
        if (format.pattern.contains('\\d{4})-(\\d{2})-(\\d{2})')) {
          return DateTime(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
          );
        }
        return DateTime(
          int.parse(match.group(3)!),
          int.parse(match.group(2)!),
          int.parse(match.group(1)!),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Widget _miniStat(
    IconData icon,
    String title,
    String value,
    Color color,
  ) =>
      LCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _action(
    BuildContext context,
    IconData icon,
    String text,
    String route,
    Color bg,
    Color color,
  ) =>
      InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, route);

          setState(() {
            dashboardFuture = _loadDashboard();
          });
        },
        child: LCard(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _upNext(
    IconData icon,
    String title,
    String sub,
    Color dot,
  ) =>
      Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF1FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(radius: 5, backgroundColor: dot),
        ],
      );

  Color _taskColor(String due) {
    final text = due.toLowerCase();

    if (text.contains('today') || text.contains('tomorrow')) {
      return AppColors.red;
    } else if (text.contains('2') || text.contains('3')) {
      return AppColors.orange;
    } else {
      return AppColors.green;
    }
  }
}