import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resellio/features/auth/views/login/login_screen.dart';
import 'package:resellio/features/auth/views/registration/organizer_screen.dart';

part 'auth_routes.g.dart';

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WelcomeScreen();
  }
}

@TypedGoRoute<OrganizerRegistrationRoute>(path: '/organizer/registration')
class OrganizerRegistrationRoute extends GoRouteData {
  const OrganizerRegistrationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizerRegistrationScreen();
  }
}
