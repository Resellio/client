import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:resellio/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

final router = GoRouter(
  initialLocation: '/',
  routes: $appRoutes,
  errorBuilder: (context, state) => const Text('error'),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Ticket Selling App',
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final router = GoRouter(
  //     initialLocation: '/',
  // redirect: (context, state) {
  // final isLoggedIn = true;
  // final isLoggingIn = state.uri.path == '/login';

  // // If not logged in, redirect to login
  // if (!isLoggedIn && !isLoggingIn) {
  //   return '/login';
  // }

  // If logged in and going to login, redirect to appropriate home
  // if (isLoggedIn && isLoggingIn) {
  //   if (authState.userRole == UserRole.organizer) {
  //     return '/organizer';
  //   } else {
  //     return '/user';
  //   }
  // }

  // // If at root, redirect to appropriate home
  // if (isLoggedIn && state.uri.path == '/') {
  //   if (authState.userRole == UserRole.organizer) {
  //     return '/organizer';
  //   } else {
  //     return '/user';
  //   }
  // }

  // No redirect needed
  // return null;
  // },
  //     routes: $appRoutes,
  //     // Add shell routes for bottom navigation
  //     errorBuilder: (context, state) => const Text('error'),
  //   );

  //   return MaterialApp.router(
  //     title: 'Resellio',
  //     routerConfig: router,
  //     theme: ThemeData(primarySwatch: Colors.blue),
  //   );
  //   // return const MaterialApp(home: BottomNavigationBarExample());
  // }
}
