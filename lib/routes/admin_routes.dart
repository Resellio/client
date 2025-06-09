import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resellio/features/admin/home/views/home_screen.dart';
import 'package:resellio/features/admin/manage_organizers/views/manage_organizers_screen.dart';
import 'package:resellio/features/admin/profile/views/profile_screen.dart';
import 'package:resellio/features/admin/shell_screen.dart';

part 'admin_routes.g.dart';

@TypedStatefulShellRoute<AdminShellRouteData>(
  branches: [
    TypedStatefulShellBranch<AdminHomeBranchData>(
      routes: [
        TypedGoRoute<AdminHomeRoute>(path: '/admin'),
      ],
    ),
    TypedStatefulShellBranch<AdminOrganizersBranchData>(
      routes: [
        TypedGoRoute<AdminOrganizersRoute>(path: '/admin/organizers'),
      ],
    ),
    TypedStatefulShellBranch<AdminProfileBranchData>(
      routes: [
        TypedGoRoute<AdminProfileRoute>(path: '/admin/profile'),
      ],
    ),
  ],
)
class AdminShellRouteData extends StatefulShellRouteData {
  const AdminShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AdminShellScreen(navigationShell: navigationShell);
  }
}

class AdminHomeBranchData extends StatefulShellBranchData {
  const AdminHomeBranchData();
}

class AdminProfileBranchData extends StatefulShellBranchData {
  const AdminProfileBranchData();
}

class AdminOrganizersBranchData extends StatefulShellBranchData {
  const AdminOrganizersBranchData();
}

class AdminHomeRoute extends GoRouteData {
  const AdminHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdminHomeScreen();
  }
}

class AdminOrganizersRoute extends GoRouteData {
  const AdminOrganizersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdminManageOrganizersScreen();
  }
}

class AdminProfileRoute extends GoRouteData {
  const AdminProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdminProfileScreen();
  }
}
