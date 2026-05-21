# Member 5 – Progress & Performance Tracking Update

This update completes the Member 5 requirement in a backend-connected, real-world style.

## Requirement Coverage

1. Progress Dashboard
   - Shows completed tasks, total study hours, average score, active goals.
   - Loads summary from backend API.
   - Search and filter progress entries.

2. Course Progress Screen
   - Loads active course progress from backend.
   - Displays progress bars, instructor, semester, and progress status.

3. Performance Chart Screen
   - Loads weekly study-hour statistics from backend.
   - Displays a simple bar chart UI for Mon–Sun performance.

4. Add Progress Entry Screen
   - Form includes task, score/status, study hours, entry date, status, and week day.
   - Saves to backend database.

5. Goals Setting Screen
   - Create, view, edit, and delete academic goals.
   - Saves goals in backend database.

## Backend APIs Added / Improved

- GET /api/progress
- GET /api/progress?status=Completed
- GET /api/progress?search=keyword
- GET /api/progress/summary
- GET /api/progress/weekly-stats
- GET /api/course-progress
- POST /api/progress
- PUT /api/progress/{id}
- DELETE /api/progress/{id}
- GET /api/goals
- POST /api/goals
- PUT /api/goals/{id}
- DELETE /api/goals/{id}

## Real-world features

- User-specific progress records through JWT authentication.
- Backend validation using Pydantic schemas.
- SQLite persistence.
- Search and status filtering.
- Weekly performance aggregation.
- Course progress bars using course module data.
- Full CRUD for academic goals.
