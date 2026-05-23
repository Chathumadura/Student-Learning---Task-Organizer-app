import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = ApiService.notifications();
  }

  Future<void> _refresh() async {
    setState(() => future = ApiService.notifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LScaffold(
        bottomNav: true,
        currentIndex: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _topBarNoBack('Notifications')),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/notificationSettings'),
                  icon: const Icon(Icons.settings_outlined, color: AppColors.text),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<dynamic>>(
              future: future,
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final list = snap.data ?? [];
                if (list.isEmpty) return const EmptyState(title: 'No notifications');
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.muted)),
                      const SizedBox(height: 14),
                      ...list.take(4).map((n) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _notificationCard(n))),
                      const SizedBox(height: 8),
                      const Text('Earlier', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.muted)),
                      const SizedBox(height: 14),
                      ...list.skip(4).map((n) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _notificationCard(n))),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(dynamic n) {
    final type = safe(n['type'], 'Notification');
    final lower = type.toLowerCase();
    IconData icon = Icons.notifications_outlined;
    Color color = AppColors.blue;
    if (lower.contains('task') || lower.contains('assignment')) { icon = Icons.assignment_outlined; color = AppColors.blue; }
    if (lower.contains('study')) { icon = Icons.calendar_month_outlined; color = AppColors.blue; }
    if (lower.contains('progress')) { icon = Icons.track_changes; color = AppColors.green; }
    if (lower.contains('course')) { icon = Icons.menu_book_outlined; color = Colors.purple; }

    return LCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 64,
            decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(safe(n['title'], 'Notification'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 6),
                Text(safe(n['message']), style: const TextStyle(color: AppColors.muted, height: 1.35, fontSize: 12)),
                const SizedBox(height: 8),
                Text(_notificationTime(n), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 5, backgroundColor: AppColors.blue),
        ],
      ),
    );
  }

  String _notificationTime(dynamic n) {
    final raw = safe(n['time'], '').trim();
    if (raw.isNotEmpty) return raw;

    final created = safe(n['created_at'], '').trim();
    if (created.isEmpty) return 'Now';

    DateTime? when;
    try {
      when = DateTime.parse(created).toLocal();
    } catch (_) {
      return created;
    }

    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool task = true;
  bool study = true;
  bool deadline = true;
  bool weekly = true;
  bool saving = false;

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
          task = s['task_reminders'] != false;
          study = s['study_reminders'] != false;
          deadline = s['deadline_warnings'] != false;
          weekly = s['weekly_summary'] != false;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await ApiService.updateNotificationSettings({
        'task_reminders': task,
        'study_reminders': study,
        'deadline_warnings': deadline,
        'weekly_summary': weekly,
      });
      if (mounted) showSnack(context, 'Reminder settings saved');
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: LScaffold(
        child: LCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              _switchRow(Icons.notifications_outlined, 'Enable task reminders', task, (v) => setState(() => task = v)),
              _switchRow(Icons.calendar_month_outlined, 'Enable study reminders', study, (v) => setState(() => study = v)),
              _switchRow(Icons.warning_amber_outlined, 'Deadline alerts', deadline, (v) => setState(() => deadline = v)),
              _switchRow(Icons.bar_chart_outlined, 'Weekly summary', weekly, (v) => setState(() => weekly = v)),
              const SizedBox(height: 18),
              LButton(text: saving ? 'Saving...' : 'Save Settings', icon: Icons.save_outlined, onPressed: saving ? null : _save),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchRow(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.blue.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.blue)),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.blue),
        ],
      ),
    );
  }
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  String theme = 'Light Mode';
  String lang = 'English';

  @override
  void initState() {
    super.initState();
    ApiService.appSettings().then((s) {
      if (mounted) {
        setState(() {
          final savedTheme = safe(s['theme'], 'Light');
          theme = savedTheme.contains('Mode') ? savedTheme : '$savedTheme Mode';
          lang = safe(s['language'], 'English');
        });
      }
    }).catchError((_) {});
  }

  Future<void> _saveSettings() async {
    await ApiService.updateAppSettings({'theme': theme.replaceAll(' Mode', ''), 'language': lang});
    if (mounted) showSnack(context, 'Settings saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: LScaffold(
        child: Column(
          children: [
            LCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _dropdownRow(Icons.dark_mode_outlined, 'App Theme', theme, ['Light Mode', 'Dark Mode', 'System Mode'], (v) { setState(() => theme = v); _saveSettings(); }),
                  const Divider(height: 26),
                  _dropdownRow(Icons.language, 'Language', lang, ['English', 'Sinhala', 'Tamil'], (v) { setState(() => lang = v); _saveSettings(); }),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _settingsTile(Icons.notifications_none, 'Notifications', () => Navigator.pushNamed(context, '/notifications')),
            _settingsTile(Icons.chat_bubble_outline, 'Send Feedback', () => Navigator.pushNamed(context, '/feedback')),
            _settingsTile(Icons.help_outline, 'Help & Support', () => Navigator.pushNamed(context, '/help')),
            const SizedBox(height: 18),
            const Text('Version 1.0.0', style: TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _dropdownRow(IconData icon, String label, String value, List<String> options, ValueChanged<String> onChanged) {
    final actual = options.contains(value) ? value : options.first;
    return Row(
      children: [
        Icon(icon, color: AppColors.muted, size: 22),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700))),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: actual,
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: InkWell(
          onTap: onTap,
          child: Row(children: [Icon(icon, color: AppColors.muted, size: 22), const SizedBox(width: 16), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right, color: AppColors.muted)]),
        ),
      ),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final msg = TextEditingController();
  bool loading = false;
  List<dynamic> feedbacks = [];
  bool listLoading = true;
  static const String _cacheKey = 'learnova_feedback_cache';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => listLoading = true);
    try {
      try {
        feedbacks = await ApiService.feedbacks();
        await _saveCache(feedbacks);
      } catch (_) {
        feedbacks = await _readCache();
      }
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => listLoading = false);
  }

  Future<List<dynamic>> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCache(List<dynamic> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(items));
  }

  Future<void> _upsertLocalFeedback(Map<String, dynamic> item) async {
    final list = await _readCache();
    final id = item['id'];
    final index = list.indexWhere((e) => e is Map && e['id'] == id);
    if (index >= 0) {
      list[index] = item;
    } else {
      list.insert(0, item);
    }
    await _saveCache(list);
    feedbacks = list;
  }

  Future<void> _removeLocalFeedback(dynamic id) async {
    final list = await _readCache();
    list.removeWhere((e) => e is Map && e['id'] == id);
    await _saveCache(list);
    feedbacks = list;
  }

  Future<void> _send() async {
    if (msg.text.trim().isEmpty) return showSnack(context, 'Please enter feedback');
    setState(() => loading = true);
    try {
      Map<String, dynamic>? created;
      try {
        created = await ApiService.sendFeedback(msg.text.trim());
      } catch (_) {
        created = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'message': msg.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        };
      }
      await _upsertLocalFeedback(created);
      msg.clear();
      await _load();
      if (mounted) showSnack(context, 'Feedback submitted');
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _editFeedback(dynamic item) async {
    final editController = TextEditingController(text: safe(item['message']));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Feedback'),
        content: LTextField(
          controller: editController,
          label: 'Feedback text',
          hint: 'Type your feedback here...',
          maxLines: 5,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;
    if (editController.text.trim().isEmpty) return showSnack(context, 'Please enter feedback');

    try {
      final updated = {...Map<String, dynamic>.from(item), 'message': editController.text.trim()};
      try {
        await ApiService.updateFeedback(asInt(item['id']), {'message': editController.text.trim()});
      } catch (_) {}
      await _upsertLocalFeedback(updated);
      await _load();
      if (mounted) showSnack(context, 'Feedback updated');
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _deleteFeedback(int id) async {
    try {
      try {
        await ApiService.deleteFeedback(id);
      } catch (_) {}
      await _removeLocalFeedback(id);
      await _load();
      if (mounted) showSnack(context, 'Feedback deleted');
    } catch (e) {
      if (mounted) showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: LScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('We\'d love to hear your thoughts! Let us know how we can improve Learnova.', style: TextStyle(color: AppColors.muted, height: 1.4)),
                  const SizedBox(height: 18),
                  LTextField(controller: msg, label: 'Feedback text', hint: 'Type your feedback here...', maxLines: 5),
                  const SizedBox(height: 22),
                  LButton(text: loading ? 'Submitting...' : 'Submit Feedback', icon: Icons.send_outlined, onPressed: loading ? null : _send),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Your Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            if (listLoading)
              const Center(child: CircularProgressIndicator())
            else if (feedbacks.isEmpty)
              const EmptyState(title: 'No feedback yet', subtitle: 'Submit feedback to see it here.')
            else
              ...feedbacks.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(color: AppColors.blue.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.feedback_outlined, color: AppColors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(safe(f['message'], '-'), style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35)),
                                const SizedBox(height: 6),
                                Text(safe(f['created_at'], 'Now'), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _editFeedback(f),
                            icon: const Icon(Icons.edit_outlined, color: AppColors.blue),
                          ),
                          IconButton(
                            onPressed: () => _deleteFeedback(asInt(f['id'])),
                            icon: const Icon(Icons.delete_outline, color: AppColors.red),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = ApiService.help();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: LScaffold(
        child: FutureBuilder<Map<String, dynamic>>(
          future: future,
          builder: (context, snap) {
            final faqs = (snap.data?['faqs'] as List?) ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (!snap.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (faqs.isEmpty)
                  const EmptyState(title: 'No FAQs available')
                else
                  ...faqs.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(safe(f['question']), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text(safe(f['answer']), style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35)),
                            ],
                          ),
                        ),
                      )),
                const SizedBox(height: 18),
                const Text('Contact Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                LCard(
                  child: Column(
                    children: [
                      const Text('Need more help? Our support team is here for you.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 14),
                      LButton(text: 'Contact Support', icon: Icons.email_outlined, onPressed: () => showSnack(context, 'Support request noted')),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LogoutConfirmScreen extends StatelessWidget {
  const LogoutConfirmScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LScaffold(
        child: Center(
          child: LCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 58, height: 58, decoration: BoxDecoration(color: AppColors.red.withOpacity(.12), shape: BoxShape.circle), child: const Icon(Icons.logout, color: AppColors.red)),
                const SizedBox(height: 20),
                const Text('Log Out?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 12),
                const Text('Are you sure you want to log out? You will need to sign in again to access your account.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: LButton(text: 'Cancel', color: const Color(0xFFE5E7EB), onPressed: () => Navigator.pop(context))),
                    const SizedBox(width: 12),
                    Expanded(child: LButton(text: 'Yes, Log Out', color: AppColors.red, onPressed: () => _logout(context))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _topBarNoBack(String title) {
  return Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.text));
}
