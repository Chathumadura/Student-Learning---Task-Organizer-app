# Member 3 – Task & Assignment Management Update

This update completes the Member 3 requirement in a more real-world, backend-connected way.

## Requirement coverage

1. Task List Screen
   - Loads user-specific tasks from the backend.
   - Shows pending/completed status.
   - Includes search, status filters, priority filter, and task summary cards.

2. Add Task Screen
   - Form fields: task title, course, due date, priority, and description.
   - Course can be selected from the user's saved courses.
   - Saves task records to the backend database.

3. Task Details Screen
   - Loads task details using the selected task ID.
   - Shows task description, deadline, priority, course, and status.
   - Supports mark as done and delete action.

4. Edit Task Screen
   - Updates title, course, due date, priority, description, and completion status.
   - Saves changes to the backend database.

5. Task Completion Screen
   - Shows a completion success message after a task is marked as done.

## Backend API updates

- `GET /api/tasks`
- `GET /api/tasks?status=pending`
- `GET /api/tasks?status=completed`
- `GET /api/tasks?priority=High`
- `GET /api/tasks?search=keyword`
- `GET /api/tasks/summary`
- `GET /api/tasks/{id}`
- `POST /api/tasks`
- `PUT /api/tasks/{id}`
- `PUT /api/tasks/{id}/complete`
- `PUT /api/tasks/{id}/reopen`
- `DELETE /api/tasks/{id}`

## Real-world improvements added

- JWT-protected user-specific tasks
- Backend validation for task title, course, due date, and priority
- Pending/completed filtering
- Priority filtering
- Search by title, course, or description
- Summary statistics
- Backend-connected add/edit/delete/complete functions
- Clean UI with deadline, status and priority indicators
