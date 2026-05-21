
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> future;
  
  @override
  void initState() {
    super.initState();
    future = ApiService.profile();
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Map<String, dynamic>>(
          future: future,
          builder: (context, snap) {
            final p = snap.data ?? {};
            final name = safe(p['name'], 'Student');
            return LScaffold(
                bottomNav: true,
                currentIndex: 4,
                child: Column(children: [
                  const SizedBox(height: 28),
                  const Center(
                      child: Text('My Profile',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18))),
                  const SizedBox(height: 18),
                  CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFDCEBFF),
                      child: Text(_initials(name),
                          style: const TextStyle(
                              fontSize: 26,
                              color: AppColors.blue,
                              fontWeight: FontWeight.w900))),
                  const SizedBox(height: 12),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(safe(p['course'], 'Computer Science Student'),
                      style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FF),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          safe(p['email'], 'student@learnova.edu'),
                          style: const TextStyle(
                              color: AppColors.blue, fontSize: 12))),
                  const SizedBox(height: 22),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppColors.blue,
                            Color(0xFF9333EA)
                          ]),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.amber),
                        const SizedBox(width: 12),
                        const Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Go Premium',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900)),
                              Text('Unlock unlimited courses & analytics',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12))
                            ])),
                        IconButton(
                            onPressed: () => _premium(context),
                            icon: const Icon(Icons.chevron_right,
                                color: Colors.white))
                      ])),
                  const SizedBox(height: 18),
                  _menu(Icons.edit_outlined, 'Edit Profile', '/editProfile'),
                  _menu(Icons.lock_outline, 'Change Password',
                      '/changePassword'),
                  _menu(Icons.bar_chart, 'My Progress', '/progress'),
                  _menu(Icons.settings_outlined, 'Settings', '/settings'),
                  const SizedBox(height: 18),
                  LButton(
                      text: 'Log Out',
                      icon: Icons.logout,
                      color: AppColors.red,
                      onPressed: () async {
                        await ApiService.logout();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (r) => false);
                      })
                ]));
          });

  String _initials(String n) {
    final parts = n.trim().split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return n.isEmpty ? 'CP' : n.substring(0, 1).toUpperCase();
  }

  Widget _menu(IconData i, String t, String r) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(i, color: AppColors.muted)),
              title: Text(t,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.muted),
              onTap: () => Navigator.pushNamed(context, r)
                  .then((_) => setState(
                      () => future = ApiService.profile())))));

  void _premium(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        builder: (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.amber, size: 52),
              const SizedBox(height: 12),
              const Text('Unlock Premium',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                  'Supercharge your studies with advanced tools and unlimited access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 22),
              LCard(
                  child: Column(children: const [
                Text('\$39.99 /yr',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Billed annually',
                    style: TextStyle(color: AppColors.muted))
              ])),
              const SizedBox(height: 18),
              const LButton(text: 'Start 7-Day Free Trial'),
              const SizedBox(height: 20)
            ])));
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final course = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ApiService.profile();
    name.text = safe(p['name']);
    email.text = safe(p['email']);
    course.text = safe(p['course']);
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => loading = true);
    try {
      await ApiService.updateProfile({
        'name': name.text.trim(),
        'email': email.text.trim(),
        'course': course.text.trim()
      });
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: LScaffold(
          child: Column(children: [
            const SizedBox(height: 42),
            LCard(
                padding: const EdgeInsets.all(22),
                child: Column(children: [
                  CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFDCEBFF),
                      child: Text(
                          name.text.isEmpty
                              ? 'CP'
                              : name.text.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.w900))),
                  const SizedBox(height: 24),
                  LTextField(controller: name, label: 'Full Name'),
                  const SizedBox(height: 16),
                  LTextField(controller: email, label: 'Email Address'),
                  const SizedBox(height: 16),
                  LTextField(controller: course, label: 'Major / Course'),
                  const SizedBox(height: 22),
                  LButton(
                      text: loading ? 'Saving...' : 'Save Changes',
                      icon: Icons.save_outlined,
                      onPressed: loading ? null : _save)
                ]))
          ]),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20)));
}
