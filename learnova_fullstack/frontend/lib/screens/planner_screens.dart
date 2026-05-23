import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
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
      items = await ApiService.studySessions();
      summary = await ApiService.studySessionSummary();
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        onPressed: () =>
            Navigator.pushNamed(context, '/addSession').then((_) => _load()),
        child: const Icon(Icons.add),
      ),
      body: LScaffold(
        bottomNav: true,
        currentIndex: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Study Planner',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/reminders'),
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/calendar'),
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context,
                              '/addSession')
                          .then((_) => _load()),
                      icon: const Icon(Icons.add_circle, color: AppColors.blue),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            LCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.chevron_left),
                  Column(
                    children: [
                      const Text(
                        'TODAY',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        safe(summary['today'], 'May 14, 2026'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Schedule',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (items.isEmpty)
              const EmptyState(
                title: 'No sessions',
                subtitle: 'Add a study session.',
              )
            else
              ...items
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _sessionCard(s),
                      ))
                  .toList(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/addSession')
                  .then((_) => _load()),
              icon: const Icon(Icons.add),
              label: const Text('Add Study Session'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ));

  Widget _sessionCard(dynamic s) {
    final color =
        asInt(s['id']).isEven ? AppColors.orange : AppColors.blue;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EditStudyPlanScreen(sessionId: asInt(s['id'])),
        ),
      ).then((_) => _load()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              safe(s['start_time'], '10:00'),
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: LCard(
              color: color.withOpacity(.14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    safe(s['subject'], 'Study Session'),
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 15, color: color),
                      const SizedBox(width: 6),
                      Text(
                        '${safe(s['duration'], '1 hour')}',
                        style:
                            TextStyle(color: color, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddStudySessionScreen extends StatefulWidget {
  const AddStudySessionScreen({super.key});

  @override
  State<AddStudySessionScreen> createState() =>
      _AddStudySessionScreenState();
}

class EditStudyPlanScreen extends StatefulWidget {
  final int sessionId;

  const EditStudyPlanScreen({super.key, required this.sessionId});

  @override
  State<EditStudyPlanScreen> createState() =>
      _EditStudyPlanScreenState();
}

class _AddStudySessionScreenState extends State<AddStudySessionScreen> {
  final subject = TextEditingController();
  final date = TextEditingController(text: '2026-05-23');
  final start = TextEditingController(text: '10:00');
  String duration = '1 hour';
  bool loading = false;

  Future<void> _save() async {
    setState(() => loading = true);
    final data = {
      'subject': subject.text.trim(),
      'session_date': date.text.trim(),
      'start_time': start.text.trim(),
      'duration': duration,
      'reminder': '5 minutes before'
    };
    try {
      await ApiService.addStudySession(data);
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
      appBar: AppBar(title: const Text('Add Study Session')),
      body: LScaffold(
        child: Column(
          children: [
            const SizedBox(height: 46),
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  LTextField(
                    controller: subject,
                    label: 'Subject',
                    hint: 'Select subject',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: date,
                    label: 'Date',
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => pickDateForController(context, date),
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: start,
                    label: 'Start Time',
                    hint: '10:00',
                    icon: Icons.schedule,
                    readOnly: true,
                    onTap: () => pickTimeForController(context, start),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: duration,
                    items: ['30 minutes', '1 hour', '1.5 hours', '2 hours', '3 hours']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => duration = v ?? '1 hour'),
                    decoration:
                        const InputDecoration(labelText: 'Duration'),
                  ),
                  const SizedBox(height: 20),
                  LButton(
                    text: loading ? 'Saving...' : 'Save Session',
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
    subject.dispose();
    date.dispose();
    start.dispose();
    super.dispose();
  }
}

class _EditStudyPlanScreenState extends State<EditStudyPlanScreen> {
  final subject = TextEditingController();
  final date = TextEditingController(text: '2026-05-14');
  final start = TextEditingController(text: '10:00');
  String duration = '1 hour';
  bool loading = false;
  bool init = false;
  late int id;

  @override
  void initState() {
    super.initState();
    id = widget.sessionId;
    _load();
  }

  Future<void> _load() async {
    final s = await ApiService.getStudySession(id);
    subject.text = safe(s['subject']);
    date.text = safe(s['session_date']);
    start.text = safe(s['start_time']);
    duration = safe(s['duration'], '1 hour');
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => loading = true);
    final data = {
      'subject': subject.text.trim(),
      'session_date': date.text.trim(),
      'start_time': start.text.trim(),
      'duration': duration,
      'reminder': '5 minutes before'
    };
    try {
      await ApiService.updateStudySession(id, data);
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
    await ApiService.deleteStudySession(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Edit Session')),
      body: LScaffold(
        child: Column(
          children: [
            const SizedBox(height: 46),
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  LTextField(
                    controller: subject,
                    label: 'Subject',
                    hint: 'Select subject',
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: date,
                    label: 'Date',
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => pickDateForController(context, date),
                  ),
                  const SizedBox(height: 16),
                  LTextField(
                    controller: start,
                    label: 'Start Time',
                    hint: '10:00',
                    icon: Icons.schedule,
                    readOnly: true,
                    onTap: () => pickTimeForController(context, start),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: duration,
                    items: ['30 minutes', '1 hour', '1.5 hours', '2 hours', '3 hours']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => duration = v ?? '1 hour'),
                    decoration:
                        const InputDecoration(labelText: 'Duration'),
                  ),
                  const SizedBox(height: 20),
                  LButton(
                    text: loading ? 'Saving...' : 'Update Session',
                    icon: Icons.save_outlined,
                    onPressed: loading ? null : _save,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LButton(
              text: 'Delete Session',
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
    subject.dispose();
    date.dispose();
    start.dispose();
    super.dispose();
  }
}

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  final List<String> _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  List<dynamic> _items = [];
  bool _loading = true;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await ApiService.studySessions();
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  DateTime? _parseDate(dynamic raw) {
    final value = safe(raw).trim();
    if (value.isEmpty) return null;
    if (value.toLowerCase() == 'today') return _dateOnly(DateTime.now());
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return _dateOnly(parsed);
    return null;
  }

  Map<String, List<dynamic>> get _eventsByDate {
    final map = <String, List<dynamic>>{};
    for (final item in _items) {
      final d = _parseDate(item['session_date']);
      if (d == null) continue;
      final key = _dateKey(d);
      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }
    return map;
  }

  List<dynamic> get _selectedEvents => _eventsByDate[_dateKey(_selectedDate)] ?? [];

  List<DateTime?> _monthCells() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startOffset = firstDay.weekday % 7;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final total = startOffset + daysInMonth;
    final trailing = (7 - (total % 7)) % 7;
    final cellCount = total + trailing;
    return List<DateTime?>.generate(cellCount, (index) {
      final day = index - startOffset + 1;
      if (day < 1 || day > daysInMonth) return null;
      return DateTime(_currentMonth.year, _currentMonth.month, day);
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      final keepDay = _selectedDate.day > lastDay ? lastDay : _selectedDate.day;
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, keepDay);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      final keepDay = _selectedDate.day > lastDay ? lastDay : _selectedDate.day;
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, keepDay);
    });
  }

  String _eventsHeading() => 'Events on ${_shortMonths[_selectedDate.month - 1]} ${_selectedDate.day}';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: LScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            LCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_months[_currentMonth.month - 1]} ${_currentMonth.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                          IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _weekdays
                        .map(
                          (w) => Expanded(
                            child: Center(
                              child: Text(
                                w,
                                style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _monthCells().length,
                    itemBuilder: (c, i) {
                      final date = _monthCells()[i];
                      if (date == null) return const SizedBox.shrink();
                      final isSelected = _dateOnly(date) == _dateOnly(_selectedDate);
                      final hasEvent = (_eventsByDate[_dateKey(date)] ?? []).isNotEmpty;

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _selectedDate = date),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.text,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              if (hasEvent)
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : AppColors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _eventsHeading(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_selectedEvents.isEmpty)
              const EmptyState(title: 'No events on this date')
            else
              ..._selectedEvents.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            safe(e['subject']),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${safe(e['start_time'])} • ${safe(e['duration'])}',
                            style: const TextStyle(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ));
}

class ReminderSetupScreen extends StatefulWidget {
  const ReminderSetupScreen({super.key});

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> {
  bool enabled = true;
  bool email = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ApiService.notificationSettings();
      if (mounted) {
        setState(() {
          enabled = s['study_reminders'] == true;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => loading = true);
    try {
      await ApiService.updateNotificationSettings({
        'study_reminders': enabled,
        'email_reminders': email
      });
      if (mounted) {
        showSnack(context, 'Reminder settings saved');
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: LScaffold(
        child: Column(
          children: [
            const SizedBox(height: 46),
            LCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: (v) => setState(() => enabled = v),
                    title: const Text('Enable Reminders'),
                    secondary: const Icon(Icons.notifications_outlined,
                        color: AppColors.blue),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Remind me before session',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: '5 minutes before',
                    items: [
                      '5 minutes before',
                      '10 minutes before',
                      '30 minutes before',
                      '1 hour before'
                    ]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (_) {},
                    decoration: const InputDecoration(
                      labelText: 'Notification Time',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: true,
                    onChanged: (_) {},
                    title: const Text('Push Notifications'),
                  ),
                  CheckboxListTile(
                    value: email,
                    onChanged: (v) =>
                        setState(() => email = v ?? false),
                    title: const Text('Email Reminders'),
                  ),
                  const SizedBox(height: 14),
                  LButton(
                    text: loading ? 'Saving...' : 'Save Settings',
                    onPressed: loading ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ));
}
