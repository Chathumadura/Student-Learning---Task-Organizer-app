import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String filter = 'all';
  List<dynamic> items = [];
  Map<String, dynamic> summary = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final priority = filter == 'high' ? 'High' : null;
      final status =
          filter == 'all' || filter == 'high' ? null : filter;
      items = await ApiService.tasks(status: status, priority: priority);
      summary = await ApiService.taskSummary();
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          onPressed: () =>
              Navigator.pushNamed(context, '/addTask').then((_) => _load()),
          child: const Icon(Icons.add),
        ),
      ),
      body: LScaffold(
        bottomNav: true,
        currentIndex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(title: 'My Tasks', avatar: true),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Pill(
                    text: 'all',
                    active: filter == 'all',
                    onTap: () {
                      filter = 'all';
                      _load();
                    },
                  ),
                  Pill(
                    text: 'pending',
                    active: filter == 'pending',
                    onTap: () {
                      filter = 'pending';
                      _load();
                    },
                  ),
                  Pill(
                    text: 'completed',
                    active: filter == 'completed',
                    onTap: () {
                      filter = 'completed';
                      _load();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (filter != 'high')
              InkWell(
                onTap: () {
                  filter = 'high';
                  _load();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'High Priority  ${safe(summary['high_priority'], '0')}',
                    style: const TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () {
                  filter = 'all';
                  _load();
                },
                child: const Text('Clear High Priority Filter'),
              ),
            const SizedBox(height: 18),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (items.isEmpty)
              const EmptyState(
                title: 'No tasks found',
                subtitle: 'Add a task to organize assignments.',
              )
            else
              ...items
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _taskCard(t),
                      ))
                  .toList(),
          ],
        ),
      ));

  Widget _taskCard(dynamic t) {
    final done = t['completed'] == true;
    final pri = safe(t['priority'], 'Medium');
    final color = pri == 'High'
        ? AppColors.red
        : (pri == 'Low' ? AppColors.green : AppColors.orange);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskDetailsScreen(taskId: asInt(t['id'])),
        ),
      ).then((_) => _load()),
      child: LCard(
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                if (done) {
                  await ApiService.reopenTask(asInt(t['id']));
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TaskCompletionScreen(taskId: asInt(t['id'])),
                    ),
                  );
                }
                _load();
              },
              child: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? AppColors.green : AppColors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    safe(t['title'], 'Task'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    safe(t['course_name'], safe(t['course'], 'Course')),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Text(
                        safe(t['due_date'], 'No due date'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      if (!done) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.warning_amber_rounded,
                            size: 14, color: AppColors.orange),
                        const SizedBox(width: 4),
                        const Text(
                          'Due soon',
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pri,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class EditTaskScreen extends StatefulWidget {
  final int taskId;

  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final title = TextEditingController();
  final course = TextEditingController(text: 'Web Development');
  final due = TextEditingController(text: '2026-05-23');
  final desc = TextEditingController();
  String priority = 'Medium';
  bool loading = false;

  Future<void> _save() async {
    setState(() => loading = true);
    final data = {
      'title': title.text.trim(),
      'course': course.text.trim(),
      'course_name': course.text.trim(),
      'due_date': due.text.trim(),
      'priority': priority,
      'description': desc.text.trim(),
    };
    try {
      await ApiService.addTask(data);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Add New Task')),
      body: LScaffold(
        child: Column(
          children: [
            const SizedBox(height: 42),
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  LTextField(
                    controller: title,
                    label: 'Task Title',
                    hint: 'e.g. Complete Assignment 1',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: course,
                    label: 'Course',
                    hint: 'Select a course',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: due,
                    label: 'Due Date',
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => pickDateForController(context, due),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: priority,
                    items: ['Low', 'Medium', 'High']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => priority = v ?? 'Medium'),
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: desc,
                    label: 'Description',
                    hint: 'Task details',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  LButton(
                    text: loading ? 'Saving...' : 'Save Task',
                    icon: Icons.save_outlined,
                    onPressed: loading ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ));

  @override
  void dispose() {
    title.dispose();
    course.dispose();
    due.dispose();
    desc.dispose();
    super.dispose();
  }
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final title = TextEditingController();
  final course = TextEditingController(text: 'Web Development');
  final due = TextEditingController(text: '2026-05-23');
  final desc = TextEditingController();
  String priority = 'Medium';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await ApiService.getTask(widget.taskId);
    title.text = safe(t['title']);
    course.text = safe(t['course_name'], safe(t['course']));
    due.text = safe(t['due_date']);
    desc.text = safe(t['description']);
    priority = safe(t['priority'], 'Medium');
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => loading = true);
    final data = {
      'title': title.text.trim(),
      'course': course.text.trim(),
      'course_name': course.text.trim(),
      'due_date': due.text.trim(),
      'priority': priority,
      'description': desc.text.trim(),
    };
    try {
      await ApiService.updateTask(widget.taskId, data);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: LScaffold(
        child: Column(
          children: [
            const SizedBox(height: 42),
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  LTextField(
                    controller: title,
                    label: 'Task Title',
                    hint: 'e.g. Complete Assignment 1',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: course,
                    label: 'Course',
                    hint: 'Select a course',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: due,
                    label: 'Due Date',
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => pickDateForController(context, due),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: priority,
                    items: ['Low', 'Medium', 'High']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => priority = v ?? 'Medium'),
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: desc,
                    label: 'Description',
                    hint: 'Task details',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  LButton(
                    text: loading ? 'Saving...' : 'Update Task',
                    icon: Icons.save_outlined,
                    onPressed: loading ? null : _save,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LButton(
              text: 'Delete Task',
              icon: Icons.delete_outline,
              color: AppColors.red,
              onPressed: () async {
                await ApiService.deleteTask(widget.taskId);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ));

  @override
  void dispose() {
    title.dispose();
    course.dispose();
    due.dispose();
    desc.dispose();
    super.dispose();
  }
}

class TaskDetailsScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = ApiService.getTask(widget.taskId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditTaskScreen(taskId: widget.taskId),
              ),
            ).then((_) => setState(
                  () => future = ApiService.getTask(widget.taskId),
                )),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: LScaffold(
        child: FutureBuilder<Map<String, dynamic>>(
          future: future,
          builder: (c, s) {
            if (!s.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final t = s.data!;
            return Column(
              children: [
                const SizedBox(height: 40),
                LCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              safe(t['title']),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              safe(t['priority'], 'Medium'),
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _line(
                        Icons.menu_book_outlined,
                        safe(t['course_name'], safe(t['course'], 'Course')),
                      ),
                      _line(
                        Icons.calendar_today_outlined,
                        'Due: ${safe(t['due_date'])}',
                      ),
                      _line(
                        Icons.flag_outlined,
                        'Status: ${t['completed'] == true ? 'Completed' : 'Pending'}',
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        safe(t['description'], 'No description'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LButton(
                  text: t['completed'] == true
                      ? 'Reopen Task'
                      : 'Mark as Completed',
                  icon: Icons.check_circle_outline,
                  onPressed: () async {
                    if (t['completed'] == true) {
                      await ApiService.reopenTask(widget.taskId);
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TaskCompletionScreen(taskId: widget.taskId),
                        ),
                      );
                    }
                    if (mounted) {
                      setState(
                        () => future = ApiService.getTask(widget.taskId),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ));

  Widget _line(IconData i, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(i, color: AppColors.muted, size: 19),
            const SizedBox(width: 10),
            Text(t, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      );
}

class TaskCompletionScreen extends StatefulWidget {
  final int taskId;

  const TaskCompletionScreen({super.key, required this.taskId});

  @override
  State<TaskCompletionScreen> createState() => _TaskCompletionScreenState();
}

class _TaskCompletionScreenState extends State<TaskCompletionScreen> {
  bool confirm = false;
  bool loading = false;

  Future<void> _done() async {
    if (!confirm) {
      showSnack(context, 'Please confirm completion');
      return;
    }
    setState(() => loading = true);
    await ApiService.completeTask(widget.taskId);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => LScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 160),
          LCard(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.check, color: AppColors.green),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Complete Task?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Great job! Confirm that you have completed this task.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: confirm,
                  onChanged: (v) => setState(() => confirm = v ?? false),
                  title: const Text('I confirm this task is done'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: loading ? null : _done,
                        child: Text(loading ? 'Saving...' : 'Confirm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      scroll: false);
}
