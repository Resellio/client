// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $adminShellRouteData,
    ];

RouteBase get $adminShellRouteData => StatefulShellRouteData.$route(
      factory: $AdminShellRouteDataExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/admin',
              factory: $AdminHomeRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/admin/profile',
              factory: $AdminProfileRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $AdminShellRouteDataExtension on AdminShellRouteData {
  static AdminShellRouteData _fromState(GoRouterState state) =>
      const AdminShellRouteData();
}

extension $AdminHomeRouteExtension on AdminHomeRoute {
  static AdminHomeRoute _fromState(GoRouterState state) =>
      const AdminHomeRoute();

  String get location => GoRouteData.$location(
        '/admin',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AdminProfileRouteExtension on AdminProfileRoute {
  static AdminProfileRoute _fromState(GoRouterState state) =>
      const AdminProfileRoute();

  String get location => GoRouteData.$location(
        '/admin/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
