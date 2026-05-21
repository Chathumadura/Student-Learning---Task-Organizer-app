# Member 6 – Notifications & Settings Implementation

This version completes the required Member 6 screens in a backend-connected, real-world style.

## Completed screens

1. **Notifications Screen**
   - Loads automatic reminders from the backend.
   - Shows task reminders, due-soon deadline alerts, overdue alerts, study reminders, and weekly progress summary.
   - Includes refresh and quick settings access.

2. **Notification Settings Screen**
   - Backend-connected settings.
   - Enable/disable task reminders, study reminders, deadline warnings, weekly summary, and email notification preference.
   - Default notification time is saved in the backend.

3. **App Settings Screen**
   - Backend-connected theme and language settings.
   - Navigation to Notifications, Notification Settings, Feedback, and Help & Support.

4. **Feedback Screen**
   - Saves feedback text to the backend database.
   - Validation is included before submit.

5. **Help & Support Screen**
   - Loads FAQs and support email from backend API.

## Backend APIs added/used

```text
GET    /api/notifications
GET    /api/notification-settings
PUT    /api/notification-settings
GET    /api/app-settings
PUT    /api/app-settings
POST   /api/feedback
GET    /api/help
```

## Notes

The notification list is auto-generated from existing tasks, study sessions, and progress entries. It is suitable for assignment demonstration because it behaves dynamically instead of showing a static hard-coded list. Real push notifications can be added later using Flutter local notification packages.
