import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resellio/features/auth/views/login/login_screen.dart';
import 'package:resellio/features/user/events/views/event_details.dart';
import 'package:resellio/features/user/events/views/search_screen.dart';
import 'package:resellio/features/user/home/views/home_screen.dart';
import 'package:resellio/features/user/profile/views/profile_screen.dart';
import 'package:resellio/features/user/shell_screen.dart';
import 'package:resellio/features/user/tickets/views/ticket_screen.dart';
import 'package:resellio/features/user/tickets/views/tickets_screen.dart';

part 'customer_routes.g.dart';

@TypedStatefulShellRoute<CustomerShellRouteData>(
  branches: [
    TypedStatefulShellBranch<CustomerHomeBranchData>(
      routes: [
        TypedGoRoute<CustomerHomeRoute>(path: '/'),
      ],
    ),
    TypedStatefulShellBranch<CustomerSearchBranchData>(
      routes: [
        TypedGoRoute<CustomerEventsRoute>(
          path: 'events',
          routes: [
            TypedGoRoute<CustomerEventDetailRoute>(path: ':eventId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CustomerTicketsBranchData>(
      routes: [
        TypedGoRoute<CustomerTicketsRoute>(
          path: 'tickets',
          routes: [
            TypedGoRoute<TicketDetailRoute>(path: ':ticketId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CustomerProfileBranchData>(
      routes: [
        TypedGoRoute<CustomerProfileRoute>(path: 'profile'),
      ],
    ),
  ],
)
class CustomerShellRouteData extends StatefulShellRouteData {
  const CustomerShellRouteData();

  static const String $path = '/customer';

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return CustomerShellScreen(navigationShell: navigationShell);
  }

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final role = context.read<int>();

    if (role == 0) {
      return '/login';
    }

    return null;
  }
}

class CustomerHomeBranchData extends StatefulShellBranchData {
  const CustomerHomeBranchData();
}

class CustomerSearchBranchData extends StatefulShellBranchData {
  const CustomerSearchBranchData();
}

class CustomerTicketsBranchData extends StatefulShellBranchData {
  const CustomerTicketsBranchData();
}

class CustomerProfileBranchData extends StatefulShellBranchData {
  const CustomerProfileBranchData();
}

class CustomerHomeRoute extends GoRouteData {
  const CustomerHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerHomeScreen();
  }
}

class CustomerEventsRoute extends GoRouteData {
  const CustomerEventsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerSearchScreen();
  }
}

class CustomerEventDetailRoute extends GoRouteData {
  const CustomerEventDetailRoute({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CustomerEventDetails(eventId: eventId);
  }
}

class CustomerTicketsRoute extends GoRouteData {
  const CustomerTicketsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerTicketsScreen();
  }
}

class TicketDetailRoute extends GoRouteData {
  const TicketDetailRoute({required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CustomerTicketScreen(ticketId: ticketId);
  }
}

class CustomerProfileRoute extends GoRouteData {
  const CustomerProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerProfileScreen();
  }
}
