
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
            if (avatar) const CircleAvatar(radius: 25, backgroundColor: Color(0xFFDCEBFF), child: Text('CP', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800))),
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

class LTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  const LTextField({super.key, required this.controller, required this.label, this.hint = '', this.icon, this.obscure = false, this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, color: AppColors.muted),
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
