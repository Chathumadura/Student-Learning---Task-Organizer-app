import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  Map<String, dynamic> summary = {};
  List<dynamic> courses = [];
  List<dynamic> entries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      summary = await ApiService.progressSummary();
      courses = await ApiService.courseProgress();
      entries = await ApiService.progress();
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final completed = safe(summary['completed_tasks'], '0');
    final hours = safe(summary['total_study_hours'], '0');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, '/addProgress').then((_) => _load()),
        child: const Icon(Icons.add),
      ),
      body: LScaffold(
        bottomNav: true,
        currentIndex: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(context, 'My Progress'),
            const SizedBox(height: 22),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(child: _miniStat(completed, 'Tasks Done', AppColors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _miniStat('${hours}h', 'Study Time', AppColors.green)),
                ],
              ),
              const SizedBox(height: 18),
              _menuTile(Icons.trending_up, 'Course Progress', () => Navigator.pushNamed(context, '/courseProgress')),
              _menuTile(Icons.bar_chart, 'Performance Chart', () => Navigator.pushNamed(context, '/performanceChart')),
              _menuTile(Icons.track_changes, 'Goals Setting', () => Navigator.pushNamed(context, '/goals')),
              const SizedBox(height: 22),
              const Text('Recent Achievements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                const EmptyState(title: 'No progress entries yet')
              else
                LCard(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: const Color(0xFFFFF2CC), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Early Bird', style: TextStyle(fontWeight: FontWeight.w900)),
                            Text('Completed $completed tasks before noon', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return LCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.blue.withOpacity(.10), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.blue),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseProgressScreen extends StatefulWidget {
  const CourseProgressScreen({super.key});

  @override
  State<CourseProgressScreen> createState() => _CourseProgressScreenState();
}

class _CourseProgressScreenState extends State<CourseProgressScreen> {
  List<dynamic> courses = [];
  List<dynamic> entries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      courses = await ApiService.courseProgress();
      entries = await ApiService.progress();
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => loading = false);
  }

  String _weekDayFromDate(String value) {
    final input = value.trim();
    if (input.isEmpty || input.toLowerCase() == 'today') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final now = DateTime.now();
      return days[now.weekday - 1];
    }
    final parsed = DateTime.tryParse(input);
    if (parsed == null) return 'Mon';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[parsed.weekday - 1];
  }

  Future<void> _deleteEntry(int id) async {
    try {
      await ApiService.deleteProgress(id);
      await _load();
      if (mounted) showSnack(context, 'Progress entry deleted');
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editEntry(dynamic entry) async {
    final taskCtrl = TextEditingController(text: safe(entry['task']));
    final scoreCtrl = TextEditingController(text: safe(entry['score']));
    final hoursCtrl = TextEditingController(text: asDouble(entry['study_hours']).toString());
    final dateCtrl = TextEditingController(text: safe(entry['entry_date'], 'Today'));
    String statusValue = safe(entry['status'], 'Completed');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Progress Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LTextField(controller: taskCtrl, label: 'Task / Activity', hint: 'Study Session'),
              const SizedBox(height: 12),
              LTextField(controller: scoreCtrl, label: 'Score', hint: '85 or 85%'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: statusValue,
                items: ['Completed', 'In Progress', 'Pending', 'Needs Review']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => statusValue = v ?? 'Completed',
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 12),
              LTextField(controller: hoursCtrl, label: 'Study Hours', hint: '1.5', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              LTextField(
                controller: dateCtrl,
                label: 'Entry Date',
                hint: 'YYYY-MM-DD or Today',
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => pickDateForController(ctx, dateCtrl),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Update')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final entryDate = dateCtrl.text.trim().isEmpty ? 'Today' : dateCtrl.text.trim();
      await ApiService.updateProgress(asInt(entry['id']), {
        'task': taskCtrl.text.trim(),
        'score': scoreCtrl.text.trim(),
        'status': statusValue,
        'study_hours': asDouble(hoursCtrl.text),
        'entry_date': entryDate,
        'week_day': _weekDayFromDate(entryDate),
      });
      await _load();
      if (mounted) showSnack(context, 'Progress entry updated');
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Progress')),
      body: LScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (courses.isEmpty)
                const EmptyState(title: 'No course progress yet')
              else
                ...courses.map((c) => _courseCard(c)).toList(),
              const SizedBox(height: 16),
              const Text('Progress Entries', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                const EmptyState(title: 'No progress entries yet')
              else
                ...entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(safe(entry['task'], 'Progress'), style: const TextStyle(fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Score: ${safe(entry['score'], '-')}, Status: ${safe(entry['status'], '-')}',
                                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Study: ${asDouble(entry['study_hours']).toStringAsFixed(1)}h, Date: ${safe(entry['entry_date'], '-')}',
                                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editEntry(entry),
                              icon: const Icon(Icons.edit_outlined, color: AppColors.blue),
                            ),
                            IconButton(
                              onPressed: () => _deleteEntry(asInt(entry['id'])),
                              icon: const Icon(Icons.delete_outline, color: AppColors.red),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _courseCard(dynamic c) {
    final progress = asDouble(c['progress']);
    final color = progress >= 70 ? AppColors.blue : (progress >= 50 ? Colors.purple : AppColors.orange);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(safe(c['name'], 'Course'), style: const TextStyle(fontWeight: FontWeight.w900))),
                Text('${progress.round()}%', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 10,
                color: color,
                backgroundColor: const Color(0xFFEFF2F7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceChartScreen extends StatefulWidget {
  const PerformanceChartScreen({super.key});

  @override
  State<PerformanceChartScreen> createState() => _PerformanceChartScreenState();
}

class _PerformanceChartScreenState extends State<PerformanceChartScreen> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = ApiService.weeklyStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Performance')),
      body: LScaffold(
        child: FutureBuilder<List<dynamic>>(
          future: future,
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final stats = snap.data ?? [];
            final maxValue = stats.fold<double>(1, (m, e) => asDouble(e['study_hours']) > m ? asDouble(e['study_hours']) : m);
            final total = stats.fold<double>(0, (sum, e) => sum + asDouble(e['study_hours']));
            return LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Study Hours', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 230,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: stats.map((s) {
                        final hours = asDouble(s['study_hours']);
                        final label = safe(s['day'], 'Day').substring(0, safe(s['day'], 'Day').length < 3 ? safe(s['day'], 'Day').length : 3);
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 34 + (hours / maxValue * 130),
                                width: 28,
                                decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(7)),
                              ),
                              const SizedBox(height: 10),
                              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text('Total study time: ${total.toStringAsFixed(0)} hours', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AddProgressEntryScreen extends StatefulWidget {
  const AddProgressEntryScreen({super.key});

  @override
  State<AddProgressEntryScreen> createState() => _AddProgressEntryScreenState();
}

class _AddProgressEntryScreenState extends State<AddProgressEntryScreen> {
  final task = TextEditingController(text: 'Study Session');
  final score = TextEditingController(text: '85');
  final hours = TextEditingController(text: '1.5');
  final date = TextEditingController(text: '2026-05-14');
  String course = 'Web Development';
  String status = 'Completed';
  bool loading = false;

  String _weekDayFromDate(String value) {
    final input = value.trim();
    if (input.isEmpty || input.toLowerCase() == 'today') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final now = DateTime.now();
      return days[now.weekday - 1];
    }
    final parsed = DateTime.tryParse(input);
    if (parsed == null) return 'Mon';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[parsed.weekday - 1];
  }

  Future<void> _updateCourseProgressFromScore() async {
    final allCourses = await ApiService.courses();
    final selected = allCourses.where((c) => safe(c['name']) == course).toList();
    if (selected.isEmpty) return;
    final courseId = asInt(selected.first['id']);
    final current = await ApiService.getCourse(courseId);
    final existing = asDouble(current['progress']);
    final cleaned = score.text.replaceAll('%', '').trim();
    final scoreVal = double.tryParse(cleaned) ?? 0;
    final next = ((existing + scoreVal) / 2).clamp(0, 100).toDouble();
    await ApiService.updateCourse(courseId, {'progress': next});
  }

  Future<void> _save() async {
    setState(() => loading = true);
    try {
      final entryDate = date.text.trim().isEmpty ? 'Today' : date.text.trim();
      await ApiService.addProgress({
        'task': task.text.trim(),
        'score': score.text.trim(),
        'status': status,
        'study_hours': asDouble(hours.text),
        'entry_date': entryDate,
        'week_day': _weekDayFromDate(entryDate),
      });
      await _updateCourseProgressFromScore();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Entry')),
      body: LScaffold(
        child: LCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: task.text,
                items: ['Study Session', 'Assignment', 'Quiz', 'Project'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => task.text = v ?? 'Study Session',
                decoration: const InputDecoration(labelText: 'Task / Activity'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: course,
                items: ['Web Development', 'Data Structures', 'Calculus II', 'Biotechnology'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => course = v ?? 'Web Development'),
                decoration: const InputDecoration(labelText: 'Course'),
              ),
              const SizedBox(height: 16),
              LTextField(controller: hours, label: 'Duration (Hours) or Score', hint: 'e.g. 60 or 95', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              LTextField(
                controller: date,
                label: 'Entry Date',
                hint: 'YYYY-MM-DD or Today',
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => pickDateForController(context, date),
              ),
              const SizedBox(height: 20),
              LButton(text: loading ? 'Saving...' : 'Save Entry', icon: Icons.save_outlined, onPressed: loading ? null : _save),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalsSettingScreen extends StatefulWidget {
  const GoalsSettingScreen({super.key});

  @override
  State<GoalsSettingScreen> createState() => _GoalsSettingScreenState();
}

class _GoalsSettingScreenState extends State<GoalsSettingScreen> {
  final title = TextEditingController();
  final targetDate = TextEditingController(text: '2026-12-31');
  List<dynamic> goals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      goals = await ApiService.goals();
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _create() async {
    if (title.text.trim().isEmpty) return showSnack(context, 'Please enter a goal title');
    await ApiService.addGoal({'title': title.text.trim(), 'description': 'Academic goal', 'target_date': targetDate.text.trim(), 'status': 'Active'});
    title.clear();
    await _load();
    if (mounted) showSnack(context, 'Goal created');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Goal')),
      body: LScaffold(
        child: Column(
          children: [
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Container(width: 62, height: 62, decoration: const BoxDecoration(color: Color(0xFFFFE9D0), shape: BoxShape.circle), child: const Icon(Icons.track_changes, color: AppColors.orange, size: 32)),
                  const SizedBox(height: 22),
                  LTextField(controller: title, label: 'Goal Title', hint: 'e.g. Finish all assignments early'),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: targetDate,
                    label: 'Target Date',
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => pickDateForController(context, targetDate),
                  ),
                  const SizedBox(height: 20),
                  LButton(text: 'Create Goal', onPressed: _create),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (loading)
              const CircularProgressIndicator()
            else
              ...goals.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.flag_outlined, color: AppColors.orange),
                        title: Text(safe(g['title']), style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('Target: ${safe(g['target_date'], '-')}', style: const TextStyle(color: AppColors.muted)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.red),
                          onPressed: () async {
                            await ApiService.deleteGoal(asInt(g['id']));
                            await _load();
                          },
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

Widget _topBar(BuildContext context, String title) {
  return Row(
    children: [
      IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back, size: 22)),
      const SizedBox(width: 4),
      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
    ],
  );
}
