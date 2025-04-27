// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $customerShellRouteData,
    ];

RouteBase get $customerShellRouteData => StatefulShellRouteData.$route(
      factory: $CustomerShellRouteDataExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/app',
              factory: $CustomerHomeRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/app/events',
              factory: $CustomerEventsRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':eventId',
                  factory: $CustomerEventDetailRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/app/tickets',
              factory: $CustomerTicketsRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':ticketId',
                  factory: $TicketDetailRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/app/profile',
              factory: $CustomerProfileRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $CustomerShellRouteDataExtension on CustomerShellRouteData {
  static CustomerShellRouteData _fromState(GoRouterState state) =>
      const CustomerShellRouteData();
}

extension $CustomerHomeRouteExtension on CustomerHomeRoute {
  static CustomerHomeRoute _fromState(GoRouterState state) =>
      const CustomerHomeRoute();

  String get location => GoRouteData.$location(
        '/app',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomerEventsRouteExtension on CustomerEventsRoute {
  static CustomerEventsRoute _fromState(GoRouterState state) =>
      const CustomerEventsRoute();

  String get location => GoRouteData.$location(
        '/app/events',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomerEventDetailRouteExtension on CustomerEventDetailRoute {
  static CustomerEventDetailRoute _fromState(GoRouterState state) =>
      CustomerEventDetailRoute(
        eventId: state.pathParameters['eventId']!,
      );

  String get location => GoRouteData.$location(
        '/app/events/${Uri.encodeComponent(eventId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomerTicketsRouteExtension on CustomerTicketsRoute {
  static CustomerTicketsRoute _fromState(GoRouterState state) =>
      const CustomerTicketsRoute();

  String get location => GoRouteData.$location(
        '/app/tickets',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $TicketDetailRouteExtension on TicketDetailRoute {
  static TicketDetailRoute _fromState(GoRouterState state) => TicketDetailRoute(
        ticketId: state.pathParameters['ticketId']!,
      );

  String get location => GoRouteData.$location(
        '/app/tickets/${Uri.encodeComponent(ticketId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomerProfileRouteExtension on CustomerProfileRoute {
  static CustomerProfileRoute _fromState(GoRouterState state) =>
      const CustomerProfileRoute();

  String get location => GoRouteData.$location(
        '/app/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
