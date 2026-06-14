class DashboardStats {
  final int totalProperties;
  final int availableProperties;
  final int totalUsers;
  final int unreadMessages;

  DashboardStats({
    required this.totalProperties,
    required this.availableProperties,
    required this.totalUsers,
    required this.unreadMessages,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProperties: json['total_properties'] as int? ?? 0,
      availableProperties: json['available_properties'] as int? ?? 0,
      totalUsers: json['total_users'] as int? ?? 0,
      unreadMessages: json['unread_messages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_properties': totalProperties,
      'available_properties': availableProperties,
      'total_users': totalUsers,
      'unread_messages': unreadMessages,
    };
  }
}
