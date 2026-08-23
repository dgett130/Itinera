import 'package:go_router/go_router.dart';

import 'features/auth/auth_screen.dart';
import 'features/auth/password_reset_screen.dart';
import 'features/auth/profile_screen.dart';
import 'features/friends/friends_screen.dart';
import 'features/itinerary/itinerary_screen.dart';
import 'features/members/members_screen.dart';
import 'features/onboarding/root_gate.dart';
import 'features/packing/packing_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/transport/transport_screen.dart';
import 'features/trip/trip_detail_screen.dart';
import 'features/trip/trip_form_screen.dart';

/// Configurazione di navigazione dell'app.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RootGate(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/friends',
      builder: (context, state) => const FriendsScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const PasswordResetScreen(),
    ),
    GoRoute(
      path: '/trip/new',
      builder: (context, state) => const TripFormScreen(),
    ),
    GoRoute(
      path: '/trip/:id',
      builder: (context, state) =>
          TripDetailScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trip/:id/edit',
      builder: (context, state) =>
          TripFormScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trip/:id/packing',
      builder: (context, state) =>
          PackingScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trip/:id/transport',
      builder: (context, state) =>
          TransportScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trip/:id/itinerary',
      builder: (context, state) =>
          ItineraryScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trip/:id/members',
      builder: (context, state) =>
          MembersScreen(tripId: state.pathParameters['id']!),
    ),
  ],
);
