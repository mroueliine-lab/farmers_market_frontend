import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/farmers/presentation/farmer_search_screen.dart';
import '../features/farmers/presentation/farmer_profile_screen.dart';
import '../features/farmers/presentation/create_farmer_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/debts/presentation/farmer_debts_screen.dart';




class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(location),
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/home'); break;
            case 1: context.go('/farmers'); break;
            case 2: context.go('/cart'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Farmers'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/farmers')) return 1;
    if (location.startsWith('/cart')) return 2;
    return 0;
  }
}

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final user = _ref.read(authProvider);
    final isLoggedIn = user != null;
    final isOnLogin = state.uri.toString() == '/login';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn && isOnLogin) return '/home';
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

          GoRoute(path: '/farmers', builder: (context, state) => const FarmerSearchScreen()),
          GoRoute(path: '/farmers/create', builder: (context, state) => const CreateFarmerScreen()),
          GoRoute(
            path: '/farmers/:id',
            builder: (context, state) => FarmerProfileScreen(
              farmerId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
          GoRoute(
            path: '/debts/:farmerId',
            builder: (context, state) => FarmerDebtsScreen(
              farmerId: int.parse(state.pathParameters['farmerId']!),
            ),
          ),
        ],
      ),
    ],
  );
});