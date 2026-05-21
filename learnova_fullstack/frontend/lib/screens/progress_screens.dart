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
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = ApiService.courseProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Progress')),
      body: LScaffold(
        child: FutureBuilder<List<dynamic>>(
          future: future,
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final list = snap.data ?? [];
            if (list.isEmpty) return const EmptyState(title: 'No course progress yet');
            return Column(children: list.map((c) => _courseCard(c)).toList());
          },
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
            final maxValue = stats.fold<double>(1, (m, e) => asDouble(e['hours']) > m ? asDouble(e['hours']) : m);
            final total = stats.fold<double>(0, (sum, e) => sum + asDouble(e['hours']));
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
                        final hours = asDouble(s['hours']);
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

  Future<void> _save() async {
    setState(() => loading = true);
    try {
      await ApiService.addProgress({
        'task': task.text.trim(),
        'score': score.text.trim(),
        'status': status,
        'study_hours': asDouble(hours.text),
        'entry_date': date.text.trim(),
      });
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
              LTextField(controller: hours, label: 'Duration (minutes) or Score', hint: 'e.g. 60 or 95', keyboardType: TextInputType.number),
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
                  LTextField(controller: targetDate, label: 'Target Date', hint: 'YYYY-MM-DD', icon: Icons.calendar_today_outlined),
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
