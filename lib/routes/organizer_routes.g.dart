// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $organizerShellRouteData,
    ];

RouteBase get $organizerShellRouteData => StatefulShellRouteData.$route(
      factory: $OrganizerShellRouteDataExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/',
              factory: $OrganizerHomeRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/events',
              factory: $OrganizerEventsRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':eventId',
                  factory: $OrganizerEventDetailRouteExtension._fromState,
                ),
                GoRouteData.$route(
                  path: 'new',
                  factory: $OrganizerNewEventRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/profile',
              factory: $OrganizerProfileRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $OrganizerShellRouteDataExtension on OrganizerShellRouteData {
  static OrganizerShellRouteData _fromState(GoRouterState state) =>
      const OrganizerShellRouteData();
}

extension $OrganizerHomeRouteExtension on OrganizerHomeRoute {
  static OrganizerHomeRoute _fromState(GoRouterState state) =>
      const OrganizerHomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OrganizerEventsRouteExtension on OrganizerEventsRoute {
  static OrganizerEventsRoute _fromState(GoRouterState state) =>
      const OrganizerEventsRoute();

  String get location => GoRouteData.$location(
        '/events',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OrganizerEventDetailRouteExtension on OrganizerEventDetailRoute {
  static OrganizerEventDetailRoute _fromState(GoRouterState state) =>
      OrganizerEventDetailRoute(
        eventId: state.pathParameters['eventId']!,
      );

  String get location => GoRouteData.$location(
        '/events/${Uri.encodeComponent(eventId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OrganizerNewEventRouteExtension on OrganizerNewEventRoute {
  static OrganizerNewEventRoute _fromState(GoRouterState state) =>
      const OrganizerNewEventRoute();

  String get location => GoRouteData.$location(
        '/events/new',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OrganizerProfileRouteExtension on OrganizerProfileRoute {
  static OrganizerProfileRoute _fromState(GoRouterState state) =>
      const OrganizerProfileRoute();

  String get location => GoRouteData.$location(
        '/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
