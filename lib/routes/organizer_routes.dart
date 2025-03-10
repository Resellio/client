import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resellio/features/organizer/events/views/event_details.dart';
import 'package:resellio/features/organizer/events/views/events_screen.dart';
import 'package:resellio/features/organizer/events/views/new_event_screen.dart';
import 'package:resellio/features/organizer/home/views/home_screen.dart';
import 'package:resellio/features/organizer/profile/views/profile_screen.dart';

part 'organizer_routes.g.dart';

@TypedStatefulShellRoute<OrganizerShellRouteData>(
  branches: [
    TypedStatefulShellBranch<OrganizerHomeBranchData>(
      routes: [
        TypedGoRoute<OrganizerHomeRoute>(path: '/'),
      ],
    ),
    TypedStatefulShellBranch<OrganizerSearchBranchData>(
      routes: [
        TypedGoRoute<OrganizerEventsRoute>(
          path: '/events',
          routes: [
            TypedGoRoute<OrganizerEventDetailRoute>(path: ':eventId'),
            TypedGoRoute<OrganizerNewEventRoute>(path: 'new'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<OrganizerProfileBranchData>(
      routes: [
        TypedGoRoute<OrganizerProfileRoute>(path: '/profile'),
      ],
    ),
  ],
)
class OrganizerShellRouteData extends StatefulShellRouteData {
  const OrganizerShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  }
}

class OrganizerHomeBranchData extends StatefulShellBranchData {
  const OrganizerHomeBranchData();
}

class OrganizerSearchBranchData extends StatefulShellBranchData {
  const OrganizerSearchBranchData();
}

class OrganizerProfileBranchData extends StatefulShellBranchData {
  const OrganizerProfileBranchData();
}

class OrganizerHomeRoute extends GoRouteData {
  const OrganizerHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizerHomeScreen();
  }
}

class OrganizerEventsRoute extends GoRouteData {
  const OrganizerEventsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizerEventsScreen();
  }
}

class OrganizerEventDetailRoute extends GoRouteData {
  const OrganizerEventDetailRoute({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OrganizerEventDetailsScreen(eventId: eventId);
  }
}

class OrganizerNewEventRoute extends GoRouteData {
  const OrganizerNewEventRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizerNewEventScreen();
  }
}

class OrganizerProfileRoute extends GoRouteData {
  const OrganizerProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizerProfileScreen();
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
            label: 'Główna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Moje wydarzenia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
