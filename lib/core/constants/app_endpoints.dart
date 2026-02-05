class AppEndpoints {
  // Base URL
  static const String baseUrl = 'https://your-api-url.com/api';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  
  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';
  
  // Attendance Endpoints
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceDetail = '/attendance/detail';
  
  // Employee Endpoints (Admin)
  static const String employees = '/employees';
  static const String employeeDetail = '/employees/detail';
  static const String createEmployee = '/employees/create';
  static const String updateEmployee = '/employees/update';
  static const String deleteEmployee = '/employees/delete';
  
  // Report Endpoints (Admin)
  static const String reportDaily = '/reports/daily';
  static const String reportMonthly = '/reports/monthly';
  static const String reportExport = '/reports/export';
}
