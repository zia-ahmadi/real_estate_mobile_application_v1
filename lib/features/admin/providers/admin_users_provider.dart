import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../properties/providers/property_provider.dart';
import '../../auth/data/auth_models.dart';

enum AdminUsersStatus { initial, loading, loaded, error }

class AdminUsersState {
  final AdminUsersStatus status;
  final List<User> users;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? error;

  AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.error,
  });

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<User>? users,
    int? currentPage,
    int? lastPage,
    int? total,
    String? error,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      error: error ?? this.error,
    );
  }
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final ApiService _apiService;

  AdminUsersNotifier(this._apiService) : super(AdminUsersState());

  Future<void> loadUsers({int page = 1}) async {
    state = state.copyWith(status: AdminUsersStatus.loading, error: null);

    try {
      final response = await _apiService.getUsers(page: page);
      final users = (response['data'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        status: AdminUsersStatus.loaded,
        users: users,
        currentPage: response['meta']['current_page'] as int,
        lastPage: response['meta']['last_page'] as int,
        total: response['meta']['total'] as int,
      );
    } catch (e) {
      state = state.copyWith(
        status: AdminUsersStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> toggleBlockUser(int userId) async {
    try {
      final response = await _apiService.toggleBlockUser(userId);
      final updatedUser = User.fromJson(response);

      // Update the user in the list
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return updatedUser;
        }
        return user;
      }).toList();

      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      // Optionally show error, but we'll just let the UI handle it
      rethrow;
    }
  }
}

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  return AdminUsersNotifier(ref.watch(apiServiceProvider));
});
