import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/course_event_bus.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  List<dynamic> items = [];
  bool loading = true;
  String q = '';
  StreamSubscription<void>? _courseSub;

  @override
  void initState() {
    super.initState();
    _load();
    // Subscribe to course changes for auto-refresh
    _courseSub = CourseEventBus.stream.listen((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _courseSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      items = await ApiService.courses(includeArchived: true);
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final list = items
        .where((e) =>
            safe(e['name'])
                .toLowerCase()
                .contains(q.toLowerCase()))
        .toList();
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          onPressed: () =>
              Navigator.pushNamed(context, '/addCourse').then((_) => _load()),
          child: const Icon(Icons.add),
        ),
      ),
      body: LScaffold(
        bottomNav: true,
        currentIndex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(title: 'My Courses', avatar: true),
            const SizedBox(height: 18),
            TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: const InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 22),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (list.isEmpty)
              const EmptyState(
                title: 'No courses found',
                subtitle: 'Create your first course.',
              )
            else
              ...list
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _courseCard(context, c),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(BuildContext context, dynamic c) {
    final p = asDouble(c['progress'], 0).clamp(0, 100);
    final colors = [
      AppColors.blue,
      Colors.purple,
      AppColors.orange,
      AppColors.green
    ];
    final color = colors[asInt(c['id']) % colors.length];
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CourseDetailsScreen(courseId: asInt(c['id'])),
        ),
      ).then((_) => _load()),
      child: LCard(
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    safe(c['name'], 'Course'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Text(
                        safe(c['instructor'], 'Instructor'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Text(
                        safe(c['semester'], 'Semester'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: p / 100,
                    color: color,
                    backgroundColor: color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                const Icon(Icons.more_horiz, color: AppColors.muted),
                const SizedBox(height: 28),
                Text(
                  '${p.round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class EditCourseScreen extends StatefulWidget {
  final int courseId;

  const EditCourseScreen({super.key, required this.courseId});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final name = TextEditingController();
  final inst = TextEditingController();
  final sem = TextEditingController();
  final desc = TextEditingController();
  double progress = 0;
  bool loading = false;

  Future<void> _save() async {
    setState(() => loading = true);
    final data = {
      'name': name.text.trim(),
      'instructor': inst.text.trim(),
      'semester': sem.text.trim(),
      'description': desc.text.trim(),
      'progress': progress
    };
    try {
      await ApiService.addCourse(data);
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
      appBar: AppBar(
        title: const Text('Add New Course'),
      ),
      body: LScaffold(
        child: Column(
          children: [
            const SizedBox(height: 56),
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  LTextField(
                    controller: name,
                    label: 'Course Name',
                    hint: 'e.g. Web Development',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: inst,
                    label: 'Instructor Name',
                    hint: 'e.g. Dr. Smith',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: sem,
                    label: 'Semester / Term',
                    hint: 'e.g. Fall 2023',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: desc,
                    label: 'Description',
                    hint: 'Course description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Progress: ${progress.round()}%'),
                      Expanded(
                        child: Slider(
                          value: progress,
                          min: 0,
                          max: 100,
                          onChanged: (v) => setState(() => progress = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LButton(
                    text: loading ? 'Saving...' : 'Save Course',
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
    name.dispose();
    inst.dispose();
    sem.dispose();
    desc.dispose();
    super.dispose();
  }
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final name = TextEditingController();
  final inst = TextEditingController();
  final sem = TextEditingController();
  final desc = TextEditingController();
  double progress = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await ApiService.getCourse(widget.courseId);
    name.text = safe(c['name']);
    inst.text = safe(c['instructor']);
    sem.text = safe(c['semester']);
    desc.text = safe(c['description']);
    progress = asDouble(c['progress']);
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => loading = true);
    final data = {
      'name': name.text.trim(),
      'instructor': inst.text.trim(),
      'semester': sem.text.trim(),
      'description': desc.text.trim(),
      'progress': progress
    };
    try {
      await ApiService.updateCourse(widget.courseId, data);
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

  Future<void> _delete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => const DeleteCourseConfirmationDialog(),
    );
    if (yes == true) {
      await ApiService.deleteCourse(widget.courseId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
      ),
      body: LScaffold(
        child: Column(
          children: [
            const SizedBox(height: 56),
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  LTextField(
                    controller: name,
                    label: 'Course Name',
                    hint: 'e.g. Web Development',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: inst,
                    label: 'Instructor Name',
                    hint: 'e.g. Dr. Smith',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: sem,
                    label: 'Semester / Term',
                    hint: 'e.g. Fall 2023',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: desc,
                    label: 'Description',
                    hint: 'Course description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Progress: ${progress.round()}%'),
                      Expanded(
                        child: Slider(
                          value: progress,
                          min: 0,
                          max: 100,
                          onChanged: (v) => setState(() => progress = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LButton(
                    text: loading ? 'Saving...' : 'Update Course',
                    icon: Icons.save_outlined,
                    onPressed: loading ? null : _save,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LButton(
              text: 'Delete Course',
              icon: Icons.delete_outline,
              color: AppColors.red,
              onPressed: _delete,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ));

  @override
  void dispose() {
    name.dispose();
    inst.dispose();
    sem.dispose();
    desc.dispose();
    super.dispose();
  }
}

class CourseDetailsScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = ApiService.getCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditCourseScreen(courseId: widget.courseId),
              ),
            ).then((_) => setState(
                  () => future = ApiService.getCourse(widget.courseId),
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
            final d = s.data!;
            final p = asDouble(d['progress']);
            return Column(
              children: [
                const SizedBox(height: 40),
                LCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.blue.withOpacity(.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              color: AppColors.blue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  safe(d['name']),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  safe(d['instructor']),
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        safe(d['description'], 'No description'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progress'),
                          Text(
                            '${p.round()}%',
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: p / 100,
                        color: AppColors.blue,
                        backgroundColor: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: LCard(
                        child: Column(
                          children: const [
                            Icon(Icons.check_box_outlined),
                            SizedBox(height: 10),
                            Text('View Tasks'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: LCard(
                        child: Column(
                          children: const [
                            Icon(Icons.bar_chart),
                            SizedBox(height: 10),
                            Text('Analytics'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ));
}

class DeleteCourseConfirmationDialog extends StatelessWidget {
  const DeleteCourseConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: const Icon(Icons.delete_outline, color: AppColors.red),
        title: const Text('Delete Course?'),
        content: const Text(
          'Are you sure you want to delete this course? All associated tasks and data will be permanently removed.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      );
}
