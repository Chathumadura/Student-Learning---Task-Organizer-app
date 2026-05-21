# Member 2 – Course Management Update

This update completes the Course Management module in a real-world style.

## Covered Requirement Screens
1. Course List Screen – enrolled/active courses, archived filter, search, course stats
2. Add Course Screen – course name, instructor, semester, description, progress
3. Course Details Screen – full course information and progress bar
4. Edit Course Screen – update course information and progress
5. Delete / Archive Course Confirmation Screen – safe archive, restore, and permanent delete

## Backend APIs
- `GET /api/courses`
- `GET /api/courses?include_archived=true`
- `GET /api/courses/archived`
- `GET /api/courses/{id}`
- `POST /api/courses`
- `PUT /api/courses/{id}`
- `PUT /api/courses/{id}/archive`
- `PUT /api/courses/{id}/restore`
- `DELETE /api/courses/{id}`

## Real-world improvements
- All course data is saved in the backend database.
- Courses are user-specific through JWT authentication.
- Inputs are validated in frontend and backend.
- Archive is provided as a safer option than permanent delete.
- Course progress is editable using a slider and displayed with progress bars.
- List screen supports search, refresh, pull-to-refresh, empty/error states, and archived-course viewing.
