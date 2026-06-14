import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';

// Placeholder imports for screens - replace with actual imports when screens are created
// import '../../features/auth/screens/login_screen.dart';
// import '../../features/auth/screens/register_screen.dart';
// import '../../features/auth/screens/profile_screen.dart';
// import '../../features/properties/screens/property_list_screen.dart';
// import '../../features/properties/screens/property_detail_screen.dart';
// import '../../features/properties/screens/map_screen.dart';
// import '../../features/favourites/screens/favourites_screen.dart';
// import '../../features/chat/screens/chat_detail_screen.dart';
// import '../../features/admin/screens/admin_dashboard_screen.dart';

part 'app_router.g.dart';

// Auth State Provider
enum AuthStatus { initial, authenticated, unauthenticated }

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthStatus build() {
    return AuthStatus.initial;
  }
  
  Future<void> checkAuthStatus() async {
    // TODO: Check token from FlutterSecureStorage and validate with API
    // For now, default to unauthenticated
    state = AuthStatus.unauthenticated;
  }
  
  void login(String role) {
    // TODO: Store token and user role
    state = AuthStatus.authenticated;
  }
  
  void logout() {
    // TODO: Clear token
    state = AuthStatus.unauthenticated;
  }
  
  String? getUserRole() {
    // TODO: Return user role from storage
    return 'user'; // Default to 'user' for now
  }
}

// Router Provider
@riverpod
GoRouter router(Ref ref) {
  final authStatus = ref.watch(authNotifierProvider);
  final userRole = ref.watch(authNotifierProvider.notifier).getUserRole();
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authStatus == AuthStatus.authenticated;
      final isAdmin = userRole == 'admin';
      
      // Splash screen - check auth and redirect
      if (state.matchedLocation == '/') {
        if (authStatus == AuthStatus.initial) {
          return '/'; // Stay on splash screen while checking
        }
        
        if (isLoggedIn) {
          return isAdmin ? '/admin' : '/home';
        }
        
        return '/home';
      }
      
      // Auth-required routes
      final authRequiredRoutes = ['/favourites', '/chat', '/profile'];
      if (authRequiredRoutes.any((route) => state.matchedLocation.startsWith(route))) {
        if (!isLoggedIn) {
          return '/login';
        }
      }
      
      // Admin-only routes
      final adminRoutes = ['/admin'];
      if (adminRoutes.any((route) => state.matchedLocation.startsWith(route))) {
        if (!isLoggedIn) {
          return '/login';
        }
        if (!isAdmin) {
          return '/home';
        }
      }
      
      // Prevent logged-in users from accessing login/register
      if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
        if (isLoggedIn) {
          return isAdmin ? '/admin' : '/home';
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const PlaceholderScreen(title: 'Home'),
      ),
      GoRoute(
        path: '/property/:id',
        name: 'property-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlaceholderScreen(title: 'Property Detail: $id');
        },
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const PlaceholderScreen(title: 'Map'),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const PlaceholderScreen(title: 'Register'),
      ),
      GoRoute(
        path: '/favourites',
        name: 'favourites',
        builder: (context, state) => const PlaceholderScreen(title: 'Favourites'),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const PlaceholderScreen(title: 'Chat'),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) => const PlaceholderScreen(title: 'Admin Dashboard'),
      ),
      GoRoute(
        path: '/admin/listings',
        name: 'admin-listings',
        builder: (context, state) => const PlaceholderScreen(title: 'Admin Listings'),
      ),
      GoRoute(
        path: '/admin/listing/new',
        name: 'admin-add-listing',
        builder: (context, state) => const PlaceholderScreen(title: 'Add Listing'),
      ),
      GoRoute(
        path: '/admin/listing/:id/edit',
        name: 'admin-edit-listing',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlaceholderScreen(title: 'Edit Listing: $id');
        },
      ),
      GoRoute(
        path: '/admin/chats',
        name: 'admin-chats',
        builder: (context, state) => const PlaceholderScreen(title: 'Admin Chat Inbox'),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) => const PlaceholderScreen(title: 'Admin Users'),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

// Placeholder Screens (replace with actual screens)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }
  
  Future<void> _checkAuth() async {
    // TODO: Implement actual auth check
    await Future.delayed(const Duration(seconds: 2));
    // The redirect logic in router will handle navigation
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
            ),
            SizedBox(height: 24),
            Text(
              'Real Estate App',
              style: TextStyle(
                color: AppColors.background,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      body: Center(
        child: Text(
          '$title - Coming Soon',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  
  const ErrorScreen({super.key, this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error: ${error?.toString() ?? "Unknown error"}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
