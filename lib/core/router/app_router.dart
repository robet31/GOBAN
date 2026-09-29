import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import '../constants/enums.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../services/onboarding_service.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/orders/screens/order_history_screen.dart';
import '../../features/orders/screens/create_order_screen.dart';
import '../../features/orders/screens/order_tracking_screen.dart';
import '../../features/orders/screens/payment_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/technician/screens/technician_dashboard.dart';
import '../../features/technician/screens/technician_register_screen.dart';
import '../../features/technician/screens/verification_pending_screen.dart';
import '../../features/locations/screens/add_location_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/verify_technicians_screen.dart';
import '../../features/admin/screens/moderate_locations_screen.dart';
import '../../models/technician_profile.dart';
import '../widgets/app_bottom_nav.dart';

/// GoRouter configuration with role-based redirects
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      // Splash
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth routes
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => OnboardingScreen(
          onComplete: () async {
            await OnboardingService().complete();
            if (context.mounted) context.go(Routes.login);
          },
        ),
      ),
      // Customer shell with bottom nav
      ShellRoute(
        builder: (context, state, child) {
          return _CustomerShell(child: child);
        },
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: Routes.orders,
            builder: (context, state) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                return OrderHistoryScreen(
                  userId: authState.user.id,
                  role: authState.user.role,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Technician routes
      GoRoute(
        path: Routes.technicianDashboard,
        builder: (context, state) => const TechnicianDashboard(),
      ),
      GoRoute(
        path: Routes.technicianRegister,
        builder: (context, state) => const TechnicianRegisterScreen(),
      ),
      // Admin dashboard
      GoRoute(
        path: Routes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // UGC Locations
      GoRoute(
        path: Routes.addLocation,
        builder: (context, state) => const AddLocationScreen(),
      ),
      // Order creation
      GoRoute(
        path: Routes.createOrder,
        builder: (context, state) {
          final technician = state.extra as TechnicianProfile?;
          return CreateOrderScreen(technician: technician);
        },
      ),
      // Order tracking
      GoRoute(
        path: Routes.orderTracking,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      // Payment
      GoRoute(
        path: Routes.payment,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return PaymentScreen(orderId: orderId);
        },
      ),
      // Chat
      GoRoute(
        path: Routes.chat,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final currentUserId = state.extra as String? ?? '';
          return ChatScreen(orderId: orderId, currentUserId: currentUserId);
        },
      ),
      // Technician verification pending
      GoRoute(
        path: Routes.verificationPending,
        builder: (context, state) => const VerificationPendingScreen(),
      ),
      // Admin sub-screens
      GoRoute(
        path: Routes.adminVerifyTechnicians,
        builder: (context, state) => const VerifyTechniciansScreen(),
      ),
      GoRoute(
        path: Routes.adminModerateLocations,
        builder: (context, state) => const ModerateLocationsScreen(),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final isOnAuthPage = state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.register ||
        state.matchedLocation == Routes.onboarding ||
        state.matchedLocation == Routes.splash;

    if (authState is AuthUnauthenticated && !isOnAuthPage) {
      return Routes.login;
    }

    if (authState is AuthAuthenticated && isOnAuthPage) {
      switch (authState.user.role) {
        case UserRole.admin:
          return Routes.adminDashboard;
        case UserRole.technician:
          return Routes.technicianDashboard;
        case UserRole.customer:
          return Routes.home;
      }
    }

    return null;
  }
}

/// Customer shell with bottom navigation
class _CustomerShell extends StatefulWidget {
  final Widget child;

  const _CustomerShell({required this.child});

  @override
  State<_CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<_CustomerShell> {
  int _currentIndex = 0;

  static const _routes = [Routes.home, Routes.orders, Routes.profile];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
      ),
    );
  }
}
