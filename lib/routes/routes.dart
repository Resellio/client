import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resellio/features/user/events/views/event_details.dart';
import 'package:resellio/features/user/events/views/events_screen.dart';
import 'package:resellio/features/user/home/views/home_screen.dart';
import 'package:resellio/features/user/profile/views/profile_screen.dart';
import 'package:resellio/features/user/tickets/views/ticket_screen.dart';
import 'package:resellio/features/user/tickets/views/tickets_screen.dart';

part 'routes.g.dart';

@TypedStatefulShellRoute<CustomerShellRouteData>(
  branches: [
    // Home Branch
    TypedStatefulShellBranch<CustomerHomeBranchData>(
      routes: [
        TypedGoRoute<CustomerHomeRoute>(path: '/'),
      ],
    ),
    // Search Branch (Events)
    TypedStatefulShellBranch<CustomerSearchBranchData>(
      routes: [
        TypedGoRoute<CustomerEventsRoute>(
          path: '/events',
          routes: [
            TypedGoRoute<CustomerEventDetailRoute>(path: ':eventId'),
          ],
        ),
      ],
    ),
    // Tickets Branch
    TypedStatefulShellBranch<CustomerTicketsBranchData>(
      routes: [
        TypedGoRoute<CustomerTicketsRoute>(
          path: '/tickets',
          routes: [
            TypedGoRoute<TicketDetailRoute>(path: ':ticketId'),
          ],
        ),
      ],
    ),
    // Profile Branch
    TypedStatefulShellBranch<CustomerProfileBranchData>(
      routes: [
        TypedGoRoute<CustomerProfileRoute>(path: '/profile'),
      ],
    ),
  ],
)
class CustomerShellRouteData extends StatefulShellRouteData {
  const CustomerShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
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
    return const CustomerEventsScreen();
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

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
