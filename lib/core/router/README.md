# App Router Setup

This directory contains the GoRouter configuration for the Real Estate app.

## Files

- `app_router.dart` - Main router configuration with all routes and redirect logic

## Routes

### Public Routes (Guest Accessible)
- `/` - SplashScreen (checks auth state, redirects accordingly)
- `/home` - HomeScreen (property listings)
- `/property/:id` - PropertyDetailScreen (single property details)
- `/map` - MapScreen (properties on map)

### Auth Routes
- `/login` - LoginScreen
- `/register` - RegisterScreen

### Auth Required Routes (User Access)
- `/favourites` - FavouritesScreen
- `/chat` - ChatScreen (conversation with admin)
- `/profile` - ProfileScreen

### Admin Only Routes
- `/admin` - AdminDashboardScreen (stats overview)
- `/admin/listings` - AdminListingsScreen (manage properties)
- `/admin/listing/new` - AddEditListingScreen (create new property)
- `/admin/listing/:id/edit` - AddEditListingScreen (edit existing property)
- `/admin/chats` - AdminChatInboxScreen (all conversations)
- `/admin/users` - AdminUsersScreen (manage users)

## Redirect Logic

The router implements the following redirect logic:

1. **Splash Screen (`/`)**:
   - Checks auth status on app launch
   - If authenticated as admin → redirects to `/admin`
   - If authenticated as user → redirects to `/home`
   - If not authenticated → redirects to `/home`

2. **Auth Required Routes** (`/favourites`, `/chat`, `/profile`):
   - If not logged in → redirects to `/login`

3. **Admin Only Routes** (`/admin/*`):
   - If not logged in → redirects to `/login`
   - If logged in as regular user → redirects to `/home`

4. **Login/Register Routes**:
   - If already logged in as admin → redirects to `/admin`
   - If already logged in as user → redirects to `/home`

## Integration Steps

To integrate the actual screens:

1. Uncomment the screen imports at the top of `app_router.dart`
2. Replace `PlaceholderScreen` with actual screen widgets in the route builders
3. Implement the `AuthNotifier` methods:
   - `checkAuthStatus()` - Check token from FlutterSecureStorage and validate with API
   - `login(String role)` - Store token and user role after successful login
   - `logout()` - Clear token on logout
   - `getUserRole()` - Return user role from storage

4. Run code generation:
   ```bash
   flutter pub run build_runner build
   ```

## Usage Example

```dart
// Navigate to a route programmatically
context.go('/property/123');

// Navigate with query parameters
context.go('/map?city=NewYork');

// Navigate and replace current route
context.go('/home');
```

## Auth State Management

The `AuthNotifier` provider manages authentication state:

```dart
// Watch auth status
final authStatus = ref.watch(authNotifierProvider);

// Check if logged in
final isLoggedIn = authStatus == AuthStatus.authenticated;

// Login
ref.read(authNotifierProvider.notifier).login('admin');

// Logout
ref.read(authNotifierProvider.notifier).logout();
```
