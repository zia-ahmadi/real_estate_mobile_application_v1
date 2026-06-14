import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/properties/screens/property_list_screen.dart';
import '../../features/properties/screens/property_detail_screen.dart';
import '../../features/properties/screens/map_screen.dart';
import '../../features/favourites/screens/favourites_screen.dart';
import '../../features/chat/screens/chat_detail_screen.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final userRole = authState.user?.role;
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAdmin = userRole == 'admin';
      final isInitial = authState.status == AuthStatus.initial;
      
      // Splash screen - check auth and redirect
      if (state.matchedLocation == '/') {
        if (isInitial) {
          return '/'; // Stay on splash screen while checking
        }
        
        if (isAuthenticated) {
          return isAdmin ? '/admin' : '/home';
        }
        
        return '/home';
      }
      
      // Auth-required routes
      final authRequiredRoutes = ['/favourites', '/chat', '/profile'];
      if (authRequiredRoutes.any((route) => state.matchedLocation.startsWith(route))) {
        if (!isAuthenticated) {
          return '/login';
        }
      }
      
      // Admin-only routes
      final adminRoutes = ['/admin'];
      if (adminRoutes.any((route) => state.matchedLocation.startsWith(route))) {
        if (!isAuthenticated) {
          return '/login';
        }
        if (!isAdmin) {
          return '/home';
        }
      }
      
      // Prevent logged-in users from accessing login/register
      if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
        if (isAuthenticated) {
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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        name: 'property-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PropertyDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) {
          final propertyId = state.uri.queryParameters['propertyId'];
          return MapScreen(propertyId: propertyId);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/favourites',
        name: 'favourites',
        builder: (context, state) => const FavouritesScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
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
});

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
