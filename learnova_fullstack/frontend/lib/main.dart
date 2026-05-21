import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screens.dart';
import 'screens/course_screens.dart';
import 'screens/task_screens.dart';
import 'screens/planner_screens.dart';
import 'screens/progress_screens.dart';
import 'screens/settings_screens.dart';

void main() => runApp(const LearnovaApp());

class LearnovaApp extends StatelessWidget {
  const LearnovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/editProfile': (_) => const EditProfileScreen(),
        '/changePassword': (_) => const ChangePasswordScreen(),
        '/courses': (_) => const CourseListScreen(),
        '/addCourse': (_) => const AddCourseScreen(),
        '/tasks': (_) => const TaskListScreen(),
        '/addTask': (_) => const AddTaskScreen(),
        '/planner': (_) => const StudyPlannerScreen(),
        '/addSession': (_) => const AddStudySessionScreen(),
        '/calendar': (_) => const CalendarViewScreen(),
        '/reminders': (_) => const ReminderSetupScreen(),
        '/progress': (_) => const ProgressDashboardScreen(),
        '/courseProgress': (_) => const CourseProgressScreen(),
        '/performanceChart': (_) => const PerformanceChartScreen(),
        '/addProgress': (_) => const AddProgressEntryScreen(),
        '/goals': (_) => const GoalsSettingScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/notificationSettings': (_) => const NotificationSettingsScreen(),
        '/settings': (_) => const AppSettingsScreen(),
        '/feedback': (_) => const FeedbackScreen(),
        '/help': (_) => const HelpSupportScreen(),
        '/logoutConfirm': (_) => const LogoutConfirmScreen(),
      },
    );
  }
}
