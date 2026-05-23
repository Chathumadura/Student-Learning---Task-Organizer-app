
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';

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
                  _buildProfileAvatar(p),
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
                    InkWell(
                    onTap: () => _premium(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
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
                    ),
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

  Widget _buildProfileAvatar(Map<String, dynamic> profileData) {
    final name = safe(profileData['name'], 'Student');
    final profilePictureBase64 = profileData['profile_picture'];
    
    if (profilePictureBase64 != null && profilePictureBase64.toString().isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 48,
          backgroundImage: MemoryImage(base64Decode(profilePictureBase64)),
        );
      } catch (_) {
        return CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFFDCEBFF),
          child: Text(_initials(name),
              style: const TextStyle(
                  fontSize: 26,
                  color: AppColors.blue,
                  fontWeight: FontWeight.w900)),
        );
      }
    }
    
    return CircleAvatar(
      radius: 48,
      backgroundColor: const Color(0xFFDCEBFF),
      child: Text(_initials(name),
          style: const TextStyle(
              fontSize: 26,
              color: AppColors.blue,
              fontWeight: FontWeight.w900)),
    );
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
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.92,
            minChildSize: 0.82,
            maxChildSize: 0.96,
            builder: (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF2D1B69), Color(0xFF0F172A)],
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFACC15),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.workspace_premium,
                                          color: Color(0xFF1F2937),
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Unlock Premium',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Supercharge your studies with\nadvanced tools and unlimited access.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 24,
                                        offset: Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: _planTab('Monthly', false),
                                              ),
                                              Expanded(
                                                child: _planTab('Yearly', true, badge: '-20%'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        const Text(
                                          '\$39.99 /yr',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Billed annually (\$3.33/mo)',
                                          style: TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.blue,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Start 7-Day Free Trial',
                                              style: TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'No charge until trial ends. Cancel anytime.',
                                          style: TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Premium Features',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _featureItem(
                                  Icons.bolt,
                                  'Unlimited Access',
                                  'Create unlimited courses, tasks, and study sessions',
                                ),
                                _featureItem(
                                  Icons.bar_chart_outlined,
                                  'Advanced Analytics',
                                  'Deep dive into your performance with detailed charts',
                                ),
                                _featureItem(
                                  Icons.calendar_month_outlined,
                                  'Smart Scheduling',
                                  'AI-powered study plan generation and calendar sync',
                                ),
                                _featureItem(
                                  Icons.shield_outlined,
                                  'Cloud Backup',
                                  'Never lose your progress with automatic cloud sync',
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Restore Purchase', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                    Text('Terms of Service', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                    Text('Privacy Policy', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
  }

  Widget _planTab(String title, bool selected, {String? badge}) => Container(
        height: 54,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? AppColors.text : AppColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _featureItem(IconData icon, String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
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
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  String? _profilePictureBase64;
  bool _deletingPicture = false;

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
    if (p['profile_picture'] != null) {
      _profilePictureBase64 = p['profile_picture'];
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 75,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImage = image;
          _pickedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Failed to pick image: ${e.toString()}');
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImageBytes == null) return;
    setState(() => loading = true);
    try {
      await ApiService.uploadProfilePicture(_pickedImageBytes!);
      if (!mounted) return;
      _profilePictureBase64 = base64Encode(_pickedImageBytes!);
      _pickedImage = null;
      _pickedImageBytes = null;
      showSnack(context, 'Profile picture updated successfully');
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('error: ', '');
        showSnack(context, 'Upload failed: $errorMsg');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _deleteProfilePicture() async {
    setState(() => _deletingPicture = true);
    try {
      await ApiService.deleteProfilePicture();
      setState(() {
        _profilePictureBase64 = null;
        _pickedImage = null;
        _pickedImageBytes = null;
      });
      showSnack(context, 'Profile picture deleted');
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _deletingPicture = false);
    }
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
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 42),
              LCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _pickedImageBytes != null
                          ? CircleAvatar(
                              radius: 48,
                              backgroundImage: MemoryImage(_pickedImageBytes!),
                            )
                          : _profilePictureBase64 != null && _profilePictureBase64!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 48,
                                  backgroundImage: MemoryImage(
                                    base64Decode(_profilePictureBase64!),
                                  ),
                                )
                              : CircleAvatar(
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
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_pickedImageBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.blue, width: 1),
                        ),
                        child: const Text(
                          '✓ Image selected - Ready to upload',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _pickedImageBytes != null ? AppColors.blue : const Color(0xFFE5E7EB),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickedImageBytes != null && !loading
                            ? _uploadImage
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: _pickedImageBytes != null
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _pickedImageBytes == null
                                  ? 'Select photo first'
                                  : loading
                                      ? 'Uploading...'
                                      : 'Upload Photo',
                              style: TextStyle(
                                color: _pickedImageBytes != null
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_profilePictureBase64 != null && _profilePictureBase64!.isNotEmpty && _pickedImageBytes == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.red.withOpacity(0.1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _deletingPicture ? null : () => _deleteProfilePicture(),
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: AppColors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _deletingPicture ? 'Deleting...' : 'Delete Photo',
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
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
          ),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20)));
}
