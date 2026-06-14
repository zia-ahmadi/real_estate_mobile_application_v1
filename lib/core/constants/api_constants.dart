class ApiConstants {
  // Base URL - Android emulator to XAMPP
  static const String baseUrl = 'http://10.0.2.2/real-estate-api/public/api';
  
  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String user = '/user';
  
  // Property Endpoints
  static const String properties = '/properties';
  static const String propertySearch = '/properties/search';
  
  // Favourite Endpoints
  static const String favourites = '/favourites';
  
  // Conversation Endpoints
  static const String conversations = '/conversations';
  static const String messages = '/messages';
  
  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminConversations = '/admin/conversations';
  static const String adminUsers = '/admin/users';
  static const String adminBlockUser = '/admin/users';
  
  // Broadcasting
  static const String broadcastAuth = '/broadcasting/auth';
  
  // Pusher Configuration
  static const String pusherKey = 'your-pusher-key';
  static const String pusherCluster = 'your-pusher-cluster';
  static const int pusherPort = 443;
  
  // Timeout Duration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
