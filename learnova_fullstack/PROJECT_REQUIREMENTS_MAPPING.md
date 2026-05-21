# Learnova Requirement Mapping

## Common Core Screens
1. Splash Screen — `frontend/lib/screens/splash_screen.dart`
2. Login Screen — `frontend/lib/screens/auth_screens.dart`
3. Home/Dashboard — `frontend/lib/screens/dashboard_screen.dart`

## Member 1 — Authentication & Profile Management
- Sign Up Screen — `auth_screens.dart`
- Login Screen — `auth_screens.dart`
- Forgot Password Screen — `auth_screens.dart`
- Profile Screen — `profile_screens.dart`
- Edit Profile Screen — `profile_screens.dart`
- Backend: `/api/auth/*`, `/api/profile/me`

## Member 2 — Course Management
- Course List Screen — `course_screens.dart`
- Add Course Screen — `course_screens.dart`
- Course Details/Edit/Delete screens — `course_screens.dart`
- Backend: `/api/courses`

## Member 3 — Task & Assignment Management
- Task List Screen — `task_screens.dart`
- Add Task Screen — `task_screens.dart`
- Task Details/Edit/Completion screens — `task_screens.dart`
- Backend: `/api/tasks`

## Member 4 — Study Planner & Schedule
- Study Planner Overview — `planner_screens.dart`
- Add Study Session — `planner_screens.dart`
- Calendar View — `planner_screens.dart`
- Reminder Setup — `planner_screens.dart`
- Backend: `/api/study-sessions`

## Member 5 — Progress & Performance Tracking
- Progress Dashboard — `progress_screens.dart`
- Course Progress/Performance Chart UI — `progress_screens.dart`
- Add Progress Entry — `progress_screens.dart`
- Goals Setting — `progress_screens.dart`
- Backend: `/api/progress`, `/api/goals`

## Member 6 — Notifications & Settings
- Notifications Screen — `settings_screens.dart`
- Notification Settings — `settings_screens.dart`
- App Settings — `settings_screens.dart`
- Feedback — `settings_screens.dart`
- Help & Support — `settings_screens.dart`
- Backend: `/api/notification-settings`, `/api/app-settings`, `/api/feedback`, `/api/help`

## Member 3 – Task & Assignment Management

The Member 3 requirement is implemented with backend-connected task management screens:

- Task List Screen: pending/completed task list with search and filters
- Add Task Screen: task title, course, due date, priority, description form
- Task Details Screen: description, deadline, priority, course, and status
- Edit Task Screen: updates task information and completion status
- Task Completion Screen: marks tasks as done and shows completion success
