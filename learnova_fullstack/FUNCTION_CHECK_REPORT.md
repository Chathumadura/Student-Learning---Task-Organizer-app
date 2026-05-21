# Learnova Function Check Report

Backend API test result: 58 / 58 endpoints passed using FastAPI TestClient.

Checked areas:
- Health/root startup
- Authentication: register, login by email, login by Student ID, forgot password, reset password
- Profile: get profile, update profile, change password validation
- Dashboard summary
- Course Management: list, create, get, update, archive, archived list, include archived, restore, delete
- Task Management: list all, filter pending/completed/high priority, summary, create, get, update, complete, reopen, delete
- Study Planner: list, date filter, summary, create, get, update, update reminder, delete
- Progress: list, summary, weekly stats, course progress, create, update, delete
- Goals: list, create, update, delete
- Notifications & Settings: notifications, notification settings get/update, app settings get/update, feedback, help/FAQs

Frontend code-level check:
- All named routes referenced in UI exist in main.dart.
- API endpoint names in ApiService match backend routes.
- Fixed Study Planner form field mismatch: frontend now sends `start_time`, `duration`, and `reminder` to match backend schema.
- Fixed Progress Dashboard to use `total_study_hours` returned by backend.
- Fixed Add Progress Entry to save to backend.
- Fixed Goals screen to load/add/delete goals through backend.
- Fixed Notification Settings and App Settings screens to load/update backend settings.
- Fixed Help screen to load FAQs from backend.

Note: Flutter emulator/analyzer is not available in this environment, so the frontend was checked by code review/static route matching rather than device execution.
