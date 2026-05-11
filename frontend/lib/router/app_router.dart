import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../store/index.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/food_list_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/payment_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    // Wait for SharedPreferences session restore before redirecting
    if (provider.isInitializing) return null;

    final loggedIn = provider.userLogin != null;
    final onAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!loggedIn && !onAuthRoute) return '/login';
    if (loggedIn && onAuthRoute) return '/categories';
    return null;
  },
  routes: [
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
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/foods/:category',
      name: 'foodList',
      builder: (context, state) {
        final category =
            Uri.decodeComponent(state.pathParameters['category'] ?? '');
        return FoodListScreen(category: category);
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) => const PaymentScreen(),
    ),
  ],
);
