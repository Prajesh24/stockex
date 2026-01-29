class ApiEndpoints {
  ApiEndpoints._();

  // 🔗 Base URL
  static const String baseUrl = "http://10.0.2.2:5050/api/auth";

  // ⏱ Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========= AUTH ENDPOINTS =========
  static const String register = "/register";
  static const String login = "/login";

  // ========= UPDATE ENDPOINTS =========
  static const String updateProfile = "/update-profile";
  static const String uploadProfilePicture = "/upload-profile-picture";
  static const String getUserProfile = "/profile";
}
