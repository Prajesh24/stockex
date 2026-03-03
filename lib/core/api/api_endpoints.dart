// lib/core/api/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._();

  // 🔗 Base URL
  static const String baseUrl = "http://10.0.2.2:5050/api";

  // ⏱ Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========= AUTH ENDPOINTS =========
  static const String register = "/auth/register";
  static const String login = "/auth/login";
  static const String updateProfile = "/auth/update-profile";
  // static const String uploadProfilePicture = "/auth/upload-profile-picture";
  static const String getUserProfile = "/auth/whoami";

  // ========= WATCHLIST ENDPOINTS =========
  static const String watchlist = "/watchlist";
  static String removeFromWatchlist(String symbol) => "/watchlist/$symbol";

  // ========= PORTFOLIO ENDPOINTS =========
  static const String portfolio = "/portfolio";
  static const String portfolioOverview = "/portfolio/overview";
  static const String sellHistory = "/portfolio/sell-history";
  static String sellStock(String id) => "/portfolio/$id/sell";
  static String removeStock(String id) => "/portfolio/$id";
}
