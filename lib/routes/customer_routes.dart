import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/user/cart/views/cart_screen.dart';
import 'package:resellio/features/user/events/bloc/events_cubit.dart';
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
        TypedGoRoute<CustomerHomeRoute>(
          path: '/app',
          routes: [
            TypedGoRoute<CustomerShoppingCartRoute>(path: '/cart'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CustomerSearchBranchData>(
      routes: [
        TypedGoRoute<CustomerEventsRoute>(
          path: '/app/events',
          routes: [
            TypedGoRoute<CustomerEventDetailRoute>(path: ':eventId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CustomerTicketsBranchData>(
      routes: [
        TypedGoRoute<CustomerTicketsRoute>(
          path: '/app/tickets',
          routes: [
            TypedGoRoute<TicketDetailRoute>(path: ':ticketId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CustomerProfileBranchData>(
      routes: [
        TypedGoRoute<CustomerProfileRoute>(path: '/app/profile'),
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
    return BlocProvider<EventsCubit>(
      create: (context) => EventsCubit(
        apiService: context.read<ApiService>(),
      )..applyFiltersAndFetch(
          token: context.read<AuthCubit>().token,
        ),
      child: CustomerShellScreen(navigationShell: navigationShell),
    );
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
    return CustomerEventDetailsScreen(eventId: eventId);
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

class CustomerShoppingCartRoute extends GoRouteData {
  const CustomerShoppingCartRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerShoppingCartScreen();
  }
}
