import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../properties/providers/property_provider.dart';
import '../data/admin_models.dart';

enum AdminStatus { initial, loading, loaded, error }

class AdminState {
  final AdminStatus status;
  final DashboardStats? stats;
  final String? error;

  AdminState({
    this.status = AdminStatus.initial,
    this.stats,
    this.error,
  });

  AdminState copyWith({
    AdminStatus? status,
    DashboardStats? stats,
    String? error,
  }) {
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final ApiService _apiService;

  AdminNotifier(this._apiService) : super(AdminState());

  Future<void> loadDashboard() async {
    state = state.copyWith(status: AdminStatus.loading, error: null);
    
    try {
      final response = await _apiService.getDashboard();
      final stats = DashboardStats.fromJson(response);
      
      state = state.copyWith(
        status: AdminStatus.loaded,
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(
        status: AdminStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

// Provider
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(apiServiceProvider));
});
