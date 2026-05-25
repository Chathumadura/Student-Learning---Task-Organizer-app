import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_event_bus.dart';
import 'course_event_bus.dart';

/// Learnova API service.
///
/// Production backend: https://student-learning-task-organizer-app.onrender.com/api
class ApiService {
  static const String baseUrl =
      'https://student-learning-task-organizer-app.onrender.com/api';

  static String? token;
  static const String _tokenKey = 'learnova_auth_token';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<void> loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String value) async {
    token = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, value);
  }

  static Future<void> logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> hasValidSession() async {
    await loadSavedToken();
    if (token == null || token!.isEmpty) return false;
    try {
      await profile();
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  static Future<void> login(String identifier, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw Exception(_message(res));
    }
    await _saveToken(jsonDecode(res.body)['access_token']);
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    String? studentId,
    String course = 'BSc Undergraduate',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'Student',
        'course': course,
        if (studentId != null && studentId.trim().isNotEmpty)
          'student_id': studentId.trim(),
      }),
    );
    if (res.statusCode != 201) throw Exception(_message(res));
    await _saveToken(jsonDecode(res.body)['access_token']);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async =>
      _postMap('/auth/forgot-password', {'email': email});
  static Future<Map<String, dynamic>> resetPassword(
          String email, String newPassword, String confirmPassword) async =>
      _postMap('/auth/reset-password', {
        'email': email,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });
  static Future<Map<String, dynamic>> changePassword(String currentPassword,
          String newPassword, String confirmPassword) async =>
      _putMap('/profile/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

  static Future<Map<String, dynamic>> dashboard() async =>
      _getMap('/dashboard');
  static Future<Map<String, dynamic>> profile() async => _getMap('/profile/me');
  static Future<Map<String, dynamic>> updateProfile(
          Map<String, dynamic> data) async =>
      _putMap('/profile/me', data);

  static Future<List<dynamic>> courses({bool includeArchived = false}) async =>
      _getList(includeArchived ? '/courses?include_archived=true' : '/courses');
  static Future<List<dynamic>> archivedCourses() async =>
      _getList('/courses/archived');
  static Future<Map<String, dynamic>> getCourse(int id) async =>
      _getMap('/courses/$id');

  static Future<Map<String, dynamic>> addCourse(
      Map<String, dynamic> data) async {
    final res = await _postMap('/courses', data);
    CourseEventBus.notify();
    return res;
  }

  static Future<Map<String, dynamic>> updateCourse(
      int id, Map<String, dynamic> data) async {
    final res = await _putMap('/courses/$id', data);
    CourseEventBus.notify();
    return res;
  }

  static Future<Map<String, dynamic>> archiveCourse(int id) async {
    final res = await _putMap('/courses/$id/archive', {});
    CourseEventBus.notify();
    return res;
  }

  static Future<Map<String, dynamic>> restoreCourse(int id) async {
    final res = await _putMap('/courses/$id/restore', {});
    CourseEventBus.notify();
    return res;
  }

  static Future<void> deleteCourse(int id) async {
    await _delete('/courses/$id');
    CourseEventBus.notify();
  }

// member 3 - task management
  static Future<List<dynamic>> tasks(
      {String? status, String? priority, String? search}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all')
      params['status'] = status;
    if (priority != null && priority.isNotEmpty && priority != 'All')
      params['priority'] = priority;
    if (search != null && search.trim().isNotEmpty)
      params['search'] = search.trim();
    final query =
        params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    return _getList('/tasks$query');
  }

  static Future<Map<String, dynamic>> taskSummary() async =>
      _getMap('/tasks/summary');
  static Future<Map<String, dynamic>> getTask(int id) async =>
      _getMap('/tasks/$id');
  static Future<Map<String, dynamic>> addTask(Map<String, dynamic> data) async {
    final res = await _postMap('/tasks', data);
    TaskEventBus.notify();
    return res;
  }

  static Future<Map<String, dynamic>> updateTask(
      int id, Map<String, dynamic> data) async {
    final res = await _putMap('/tasks/$id', data);
    TaskEventBus.notify();
    return res;
  }

  static Future<Map<String, dynamic>> completeTask(int id) async {
    final res = await _putMap('/tasks/$id/complete', {});
    TaskEventBus.notify();
    return res;
  }

  static Future<Map<String, dynamic>> reopenTask(int id) async {
    final res = await _putMap('/tasks/$id/reopen', {});
    TaskEventBus.notify();
    return res;
  }

  static Future<void> deleteTask(int id) async {
    await _delete('/tasks/$id');
    TaskEventBus.notify();
  }


  static Future<List<dynamic>> studySessions(
      {String? date, String? search}) async {
    final params = <String, String>{};
    if (date != null && date.trim().isNotEmpty)
      params['session_date'] = date.trim();
    if (search != null && search.trim().isNotEmpty)
      params['search'] = search.trim();
    final query =
        params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    return _getList('/study-sessions$query');
  }

  static Future<Map<String, dynamic>> studySessionSummary() async =>
      _getMap('/study-sessions/summary');
  static Future<Map<String, dynamic>> getStudySession(int id) async =>
      _getMap('/study-sessions/$id');
  static Future<Map<String, dynamic>> addStudySession(
          Map<String, dynamic> data) async =>
      _postMap('/study-sessions', data);
  static Future<Map<String, dynamic>> updateStudySession(
          int id, Map<String, dynamic> data) async =>
      _putMap('/study-sessions/$id', data);
  static Future<Map<String, dynamic>> updateStudySessionReminder(
          int id, String reminder) async =>
      _putMap('/study-sessions/$id/reminder', {'reminder': reminder});
  static Future<void> deleteStudySession(int id) async =>
      _delete('/study-sessions/$id');

  static Future<List<dynamic>> progress(
      {String? status, String? search}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'All')
      params['status'] = status;
    if (search != null && search.trim().isNotEmpty)
      params['search'] = search.trim();
    final query =
        params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    return _getList('/progress$query');
  }

  static Future<Map<String, dynamic>> progressSummary() async =>
      _getMap('/progress/summary');
  static Future<List<dynamic>> weeklyStats() async =>
      _getList('/progress/weekly-stats');
  static Future<List<dynamic>> courseProgress() async =>
      _getList('/course-progress');
  static Future<Map<String, dynamic>> addProgress(
          Map<String, dynamic> data) async =>
      _postMap('/progress', data);
  static Future<Map<String, dynamic>> updateProgress(
          int id, Map<String, dynamic> data) async =>
      _putMap('/progress/$id', data);
  static Future<void> deleteProgress(int id) async => _delete('/progress/$id');

  static Future<List<dynamic>> goals() async => _getList('/goals');
  static Future<Map<String, dynamic>> addGoal(
          Map<String, dynamic> data) async =>
      _postMap('/goals', data);
  static Future<Map<String, dynamic>> updateGoal(
          int id, Map<String, dynamic> data) async =>
      _putMap('/goals/$id', data);
  static Future<void> deleteGoal(int id) async => _delete('/goals/$id');

  static Future<List<dynamic>> notifications() async =>
      _getList('/notifications');
  static Future<Map<String, dynamic>> notificationSettings() async =>
      _getMap('/notification-settings');
  static Future<Map<String, dynamic>> updateNotificationSettings(
          Map<String, dynamic> data) async =>
      _putMap('/notification-settings', data);

  static Future<Map<String, dynamic>> appSettings() async =>
      _getMap('/app-settings');
  static Future<Map<String, dynamic>> updateAppSettings(
          Map<String, dynamic> data) async =>
      _putMap('/app-settings', data);

  static Future<Map<String, dynamic>> sendFeedback(String message) async =>
      _postMap('/feedback', {'message': message});
    static Future<List<dynamic>> feedbacks() async => _getList('/feedbacks');
    static Future<Map<String, dynamic>> updateFeedback(
        int id, Map<String, dynamic> data) async =>
      _putMap('/feedbacks/$id', data);
    static Future<void> deleteFeedback(int id) async => _delete('/feedbacks/$id');
  static Future<Map<String, dynamic>> help() async => _getMap('/help');

  static Future<Map<String, dynamic>> uploadProfilePicture(Uint8List bytes) async {
    final base64data = base64Encode(bytes);
    final payload = jsonEncode({'profile_picture': base64data});
    
    final res = await http.put(
      Uri.parse('$baseUrl/profile/me'),
      headers: _headers,
      body: payload,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Upload timeout - image file too large or network slow'),
    );
    
    if (res.statusCode != 200) {
      throw Exception(_message(res));
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> deleteProfilePicture() async =>
      _putMap('/profile/me', {'profile_picture': null});

  static Future<Map<String, dynamic>> _getMap(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    if (res.statusCode != 200) throw Exception(_message(res));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> _getList(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    if (res.statusCode != 200) throw Exception(_message(res));
    return jsonDecode(res.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> _postMap(
      String path, Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$baseUrl$path'),
        headers: _headers, body: jsonEncode(data));
    if (res.statusCode != 200 && res.statusCode != 201)
      throw Exception(_message(res));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _putMap(
      String path, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$baseUrl$path'),
        headers: _headers, body: jsonEncode(data));
    if (res.statusCode != 200) throw Exception(_message(res));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> _delete(String path) async {
    final res =
        await http.delete(Uri.parse('$baseUrl$path'), headers: _headers);
    if (res.statusCode != 200) throw Exception(_message(res));
  }

  static String _message(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      return body['detail']?.toString() ??
          body['message']?.toString() ??
          res.body;
    } catch (_) {
      return res.body;
    }
  }
}
