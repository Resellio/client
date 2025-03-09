import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:resellio/routes/customer_routes.dart';
// import 'package:resellio/routes/organizer_routes.dart';

void main() {
  runApp(const MyApp());
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // TODO: Use auth to determine which shell route to use
    $customerShellRouteData,
    // $organizerShellRouteData,
  ],
  errorBuilder: (context, state) => const Text('error'),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Bilety na wydarzenia | Resellio',
    );
  }
}
