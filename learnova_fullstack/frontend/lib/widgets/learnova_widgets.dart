
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import '../services/api_service.dart';

class LScaffold extends StatelessWidget {
  final Widget child;
  final bool bottomNav;
  final int currentIndex;
  final bool scroll;
  final EdgeInsets padding;
  const LScaffold({super.key, required this.child, this.bottomNav = false, this.currentIndex = 0, this.scroll = true, this.padding = const EdgeInsets.fromLTRB(24, 18, 24, 20)});

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: scroll ? SingleChildScrollView(padding: padding, child: child) : Padding(padding: padding, child: child),
    );
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: body,
      bottomNavigationBar: bottomNav ? LearnovaBottomNav(currentIndex: currentIndex) : null,
    );
  }
}

class LearnovaLogo extends StatelessWidget {
  final double size;
  final bool centered;
  const LearnovaLogo({super.key, this.size = 24, this.centered = false});

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 8,
          height: size + 8,
          decoration: const BoxDecoration(color: Color(0xFFEAF1FF), shape: BoxShape.circle),
          child: Icon(Icons.school_outlined, color: AppColors.blue, size: size),
        ),
        const SizedBox(width: 10),
        Text('Learnova', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: size + 2)),
      ],
    );
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [row, const SizedBox(height: 8), const Text('Learn smart. Organize better.', style: TextStyle(color: AppColors.muted, fontSize: 13))],
    );
  }
}

class Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool avatar;
  const Header({super.key, required this.title, this.subtitle, this.avatar = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const LearnovaLogo(size: 22),
            if (avatar)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: ApiService.profile(),
                    builder: (context, profileSnap) {
                      final profileData = profileSnap.data ?? {};
                      final profilePic = profileData['profile_picture'];
                      if (profilePic != null && profilePic.toString().isNotEmpty) {
                        try {
                          return CircleAvatar(
                            radius: 25,
                            backgroundImage: MemoryImage(base64Decode(profilePic)),
                          );
                        } catch (_) {
                          // fall through to initials
                        }
                      }
                      return CircleAvatar(radius: 25, backgroundColor: Color(0xFFDCEBFF), child: Text('CP', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800)));
                    },
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text(title, style: const TextStyle(fontSize: 33, height: 1, fontWeight: FontWeight.w900, color: AppColors.text)),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(subtitle!, style: const TextStyle(fontSize: 16, color: AppColors.muted)),
        ],
      ],
    );
  }
}

class LCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  const LCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.radius = 16, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class LButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  const LButton({super.key, required this.text, this.onPressed, this.icon, this.color = AppColors.blue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, color: Colors.white, size: 18),
        label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }
}

class LTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  const LTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<LTextField> createState() => _LTextFieldState();
}

class _LTextFieldState extends State<LTextField> {
  bool _hidden = true;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure ? _hidden : false,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: AppColors.muted),
        suffixIcon: widget.obscure
            ? IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                ),
              )
            : null,
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback? onTap;
  final Color color;
  const Pill({super.key, required this.text, this.active = false, this.onTap, this.color = AppColors.blue});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: active ? Colors.white : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
          child: Text(text, style: TextStyle(color: active ? AppColors.text : AppColors.muted, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const EmptyState({super.key, this.title = 'Nothing here yet', this.subtitle = 'Add your first item to get started.'});
  @override
  Widget build(BuildContext context) {
    return LCard(child: Column(children: [const Icon(Icons.inbox_outlined, color: AppColors.muted, size: 44), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted))]));
  }
}

class LearnovaBottomNav extends StatelessWidget {
  final int currentIndex;
  const LearnovaBottomNav({super.key, required this.currentIndex});
  static const routes = ['/dashboard', '/courses', '/tasks', '/planner', '/profile'];
  static const icons = [Icons.home_outlined, Icons.menu_book_outlined, Icons.check_box_outlined, Icons.calendar_month_outlined, Icons.person_outline];
  static const labels = ['Home', 'Courses', 'Tasks', 'Planner', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 78,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, -2))]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(labels.length, (i) {
            final active = i == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () { if (!active) Navigator.pushReplacementNamed(context, routes[i]); },
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icons[i], color: active ? AppColors.blue : AppColors.muted),
                  const SizedBox(height: 4),
                  Text(labels[i], style: TextStyle(color: active ? AppColors.blue : AppColors.muted, fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String safe(dynamic value, [String fallback = '']) => value == null ? fallback : value.toString();
int asInt(dynamic value, [int fallback = 0]) => value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;
double asDouble(dynamic value, [double fallback = 0]) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? fallback;

DateTime? _parsePickerDateText(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  if (text.toLowerCase() == 'today') return DateTime.now();
  final iso = DateTime.tryParse(text);
  if (iso != null) return iso;
  return null;
}

Future<void> pickDateForController(
  BuildContext context,
  TextEditingController controller, {
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  final minDate = firstDate ?? DateTime(now.year - 10, 1, 1);
  final maxDate = lastDate ?? DateTime(now.year + 20, 12, 31);

  var initial = _parsePickerDateText(controller.text) ?? now;
  if (initial.isBefore(minDate)) initial = minDate;
  if (initial.isAfter(maxDate)) initial = maxDate;

  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: minDate,
    lastDate: maxDate,
  );
  if (picked == null) return;
  controller.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
}

TimeOfDay? _parsePickerTimeText(String raw) {
  final text = raw.trim().toLowerCase();
  if (text.isEmpty) return null;

  final normalized = text.replaceAll('.', ':').replaceAll(' ', '');
  final regex = RegExp(r'^(\d{1,2}):(\d{2})(am|pm)?$');
  final m = regex.firstMatch(normalized);
  if (m == null) return null;

  int hour = int.tryParse(m.group(1) ?? '') ?? 0;
  final minute = int.tryParse(m.group(2) ?? '') ?? 0;
  final ampm = m.group(3);

  if (ampm == 'pm' && hour < 12) hour += 12;
  if (ampm == 'am' && hour == 12) hour = 0;

  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

Future<void> pickTimeForController(BuildContext context, TextEditingController controller) async {
  final initial = _parsePickerTimeText(controller.text) ?? TimeOfDay.now();
  final picked = await showTimePicker(
    context: context,
    initialTime: initial,
  );
  if (picked == null) return;
  controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
}
