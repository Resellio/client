// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $loginRoute,
      $organizerRegistrationRoute,
      $organizerUnverifiedRoute,
    ];

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: $LoginRouteExtension._fromState,
    );

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  String get location => GoRouteData.$location(
        '/login',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $organizerRegistrationRoute => GoRouteData.$route(
      path: '/org/registration',
      factory: $OrganizerRegistrationRouteExtension._fromState,
    );

extension $OrganizerRegistrationRouteExtension on OrganizerRegistrationRoute {
  static OrganizerRegistrationRoute _fromState(GoRouterState state) =>
      const OrganizerRegistrationRoute();

  String get location => GoRouteData.$location(
        '/org/registration',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $organizerUnverifiedRoute => GoRouteData.$route(
      path: '/org/pending',
      factory: $OrganizerUnverifiedRouteExtension._fromState,
    );

extension $OrganizerUnverifiedRouteExtension on OrganizerUnverifiedRoute {
  static OrganizerUnverifiedRoute _fromState(GoRouterState state) =>
      const OrganizerUnverifiedRoute();

  String get location => GoRouteData.$location(
        '/org/pending',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
