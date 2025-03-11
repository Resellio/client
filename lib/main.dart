import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resellio/routes/auth_routes.dart';
import 'package:resellio/routes/customer_routes.dart';
import 'package:resellio/routes/organizer_routes.dart';

void main() {
  runApp(
    Provider<int>(
      create: (_) => 2,
      child: const MyApp(),
    ),
  );
}

// final router = GoRouter(
//   initialLocation: '/',
//   routes: [
//     // TODO: Use auth to determine which shell route to use
//     $customerShellRouteData,
//     // $organizerShellRouteData,
//   ],
// );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<int>();
    final GoRouter router = GoRouter(
      routes: [
        // Login route
        $loginRoute,
        // Customer shell at '/customer'
        if (role == 1) $customerShellRouteData,
        // Organizer shell at '/organizer'
        if (role == 2) $organizerShellRouteData,
      ],
      initialLocation: '/login', // Start at login if not authenticated
    );
    return MaterialApp.router(
      routerConfig: router,
      title: 'Bilety na wydarzenia | Resellio',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
      ),
    );
  }
}
