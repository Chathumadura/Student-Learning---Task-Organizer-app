# Member 4 – Study Planner & Schedule Update

This update completes the Member 4 requirement in a real-world backend-connected way.

## Completed screens

1. Study Planner Overview
   - Daily / weekly view toggle
   - Search study sessions
   - Summary cards: total sessions, planned days, reminders enabled
   - Backend-loaded sessions

2. Add Study Session Screen
   - Subject
   - Date picker
   - Time picker
   - Duration
   - Notification/reminder time
   - Saves to FastAPI + SQLite backend

3. Calendar View Screen
   - Monthly planner
   - Displays count of planned study sessions on each date
   - Tap a date to view study sessions

4. Edit Study Plan Screen
   - Update subject, date, time, duration and reminder
   - Delete study session with confirmation
   - Saves changes to backend

5. Reminder Setup Screen
   - Enable/disable study reminders
   - Enable/disable weekly summary
   - Set default notification time
   - Apply reminder time to all study sessions

## Backend APIs added/enhanced

- GET `/api/study-sessions`
- GET `/api/study-sessions?session_date=YYYY-MM-DD`
- GET `/api/study-sessions?search=keyword`
- GET `/api/study-sessions/summary`
- GET `/api/study-sessions/{id}`
- POST `/api/study-sessions`
- PUT `/api/study-sessions/{id}`
- PUT `/api/study-sessions/{id}/reminder`
- DELETE `/api/study-sessions/{id}`
- GET/PUT `/api/notification-settings`

## Requirement coverage

Member 4 – Study Planner & Schedule is now fully covered with frontend screens, backend APIs, database persistence, reminder setup and real CRUD flow.
