# Learnova — Member 1 Authentication & Profile Management Update

This update completes the Member 1 requirement in a stronger full-stack way.

## Screens covered

1. Sign Up Screen
2. Login Screen
3. Forgot Password Screen
4. Profile Screen
5. Edit Profile Screen

## Backend updates

- `POST /api/auth/register`
- `POST /api/auth/login` accepts email or student ID through `identifier`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `GET /api/profile/me`
- `PUT /api/profile/me`
- `PUT /api/profile/change-password`

## Frontend updates

- Saved login token using SharedPreferences
- Auto-login check on Splash Screen
- Profile data loaded from backend
- Edit Profile saves to backend
- Change Password screen added
- Logout clears saved token

## Demo account

Email: `student@learnova.lk`  
Student ID: `LEA-2026-001`  
Password: `password123`
