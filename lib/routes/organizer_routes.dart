import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/common/bloc/categories_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/organizer/events/bloc/events_cubit.dart';
import 'package:resellio/features/organizer/events/views/event_details.dart';
import 'package:resellio/features/organizer/events/views/events_screen.dart';
import 'package:resellio/features/organizer/events/views/new_event_screen.dart';
import 'package:resellio/features/organizer/home/views/home_screen.dart';
import 'package:resellio/features/organizer/profile/views/profile_screen.dart';
import 'package:resellio/features/organizer/shell_screen.dart';

part 'organizer_routes.g.dart';

@TypedStatefulShellRoute<OrganizerShellRouteData>(
  branches: [
    TypedStatefulShellBranch<OrganizerHomeBranchData>(
      routes: [
        TypedGoRoute<OrganizerHomeRoute>(path: '/org'),
      ],
    ),
    TypedStatefulShellBranch<OrganizerSearchBranchData>(
      routes: [
        TypedGoRoute<OrganizerEventsRoute>(
          path: '/org/events',
          routes: [
            TypedGoRoute<OrganizerNewEventRoute>(path: 'new'),
            TypedGoRoute<OrganizerEventDetailRoute>(path: ':eventId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<OrganizerProfileBranchData>(
      routes: [
        TypedGoRoute<OrganizerProfileRoute>(path: '/org/profile'),
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
    return MultiProvider(
      providers: [
        BlocProvider<OrganizerEventsCubit>(
          create: (_) => OrganizerEventsCubit(
            apiService: context.read<ApiService>(),
          )..fetchNextPage(context.read<AuthCubit>().token),
        ),
        BlocProvider<CategoriesCubit>(
          create: (_) => CategoriesCubit(
            context.read<ApiService>(),
            context.read<AuthCubit>(),
          )..getCategories(),
        ),
      ],
      child: OrganizerShellScreen(navigationShell: navigationShell),
    );
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
    return const OrganizerEventDetailsScreen();
  }
}

class OrganizerNewEventRoute extends GoRouteData {
  const OrganizerNewEventRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OrganizerNewEventScreen(
      apiService: context.read<ApiService>(),
    );
  }
}

class OrganizerProfileRoute extends GoRouteData {
  const OrganizerProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizerProfileScreen();
  }
}
