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
              path: '/org',
              factory: $OrganizerHomeRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/org/events',
              factory: $OrganizerEventsRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'new',
                  factory: $OrganizerNewEventRouteExtension._fromState,
                ),
                GoRouteData.$route(
                  path: ':eventId',
                  factory: $OrganizerEventDetailRouteExtension._fromState,
                  routes: [
                    GoRouteData.$route(
                      path: 'message',
                      factory: $OrganizerMessageToParticipantsRouteExtension
                          ._fromState,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/org/profile',
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
        '/org',
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
        '/org/events',
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
        '/org/events/new',
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
        '/org/events/${Uri.encodeComponent(eventId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OrganizerMessageToParticipantsRouteExtension
    on OrganizerMessageToParticipantsRoute {
  static OrganizerMessageToParticipantsRoute _fromState(GoRouterState state) =>
      OrganizerMessageToParticipantsRoute(
        eventId: state.pathParameters['eventId']!,
      );

  String get location => GoRouteData.$location(
        '/org/events/${Uri.encodeComponent(eventId)}/message',
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
        '/org/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
