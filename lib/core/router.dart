import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/farmers/presentation/farmer_search_screen.dart';
import '../features/farmers/presentation/farmer_profile_screen.dart';
import '../features/farmers/presentation/create_farmer_screen.dart';

// Placeholder screens — we'll replace these one by one
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home')));
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Cart')));
}

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Debts')));
}

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
            case 3: context.go('/debts'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Farmers'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Debts'),
        ],
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/farmers')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/debts')) return 3;
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
          GoRoute(path: '/debts', builder: (context, state) => const DebtsScreen()),
        ],
      ),
    ],
  );
});