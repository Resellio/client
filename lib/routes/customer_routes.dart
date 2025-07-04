import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:resellio/features/common/bloc/categories_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/user/cart/bloc/cart_cubit.dart';
import 'package:resellio/features/user/cart/views/cart_screen.dart';
import 'package:resellio/features/user/cart/views/checkout_screen.dart';
import 'package:resellio/features/user/events/bloc/event_details_cubit.dart';
import 'package:resellio/features/user/events/bloc/events_cubit.dart';
import 'package:resellio/features/user/events/views/event_details.dart';
import 'package:resellio/features/user/events/views/search_screen.dart';
import 'package:resellio/features/user/home/views/home_screen.dart';
import 'package:resellio/features/user/profile/views/profile_screen.dart';
import 'package:resellio/features/user/shell_screen.dart';
import 'package:resellio/features/user/tickets/bloc/ticket_details_cubit.dart';
import 'package:resellio/features/user/tickets/bloc/tickets_cubit.dart';
import 'package:resellio/features/user/tickets/views/ticket_screen.dart';
import 'package:resellio/features/user/tickets/views/tickets_screen.dart';

part 'customer_routes.g.dart';

@TypedStatefulShellRoute<CustomerShellRouteData>(
  branches: [
    // TypedStatefulShellBranch<CustomerHomeBranchData>(
    //   routes: [
    //     TypedGoRoute<CustomerHomeRoute>(
    //       path: '/app',
    //     ),
    //   ],
    // ),
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
            TypedGoRoute<CustomerTicketDetailRoute>(path: ':ticketId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CustomerCartBranchData>(
      routes: [
        TypedGoRoute<CustomerCartRoute>(
          path: '/app/cart',
          routes: [
            TypedGoRoute<CustomerCheckoutRoute>(path: 'checkout'),
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
    return MultiProvider(
      providers: [
        BlocProvider<EventsCubit>(
          create: (context) => EventsCubit(
            apiService: context.read<ApiService>(),
          )..applyFiltersAndFetch(),
        ),
        BlocProvider<CategoriesCubit>(
          create: (context) => CategoriesCubit(
            context.read<ApiService>(),
          )..getCategories(),
        ),
        BlocProvider<CartCubit>(
          create: (context) => CartCubit(
            apiService: context.read<ApiService>(),
          )..fetchCart(),
        ),
        BlocProvider(
          create: (context) => TicketsCubit(
            apiService: context.read<ApiService>(),
          )..loadTickets(),
        ),
      ],
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

class CustomerCartBranchData extends StatefulShellBranchData {
  const CustomerCartBranchData();
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
    return BlocProvider(
      create: (context) => EventDetailsCubit(
        context.read<ApiService>(),
      )..loadEventDetails(eventId),
      child: CustomerEventDetailsScreen(eventId: eventId),
    );
  }
}

class CustomerTicketsRoute extends GoRouteData {
  const CustomerTicketsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerTicketsScreen();
  }
}

class CustomerTicketDetailRoute extends GoRouteData {
  const CustomerTicketDetailRoute({required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => TicketDetailsCubit(
        apiService: context.read<ApiService>(),
      )..loadTicketDetails(ticketId),
      child: CustomerTicketScreen(ticketId: ticketId),
    );
  }
}

class CustomerProfileRoute extends GoRouteData {
  const CustomerProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerProfileScreen();
  }
}

class CustomerCartRoute extends GoRouteData {
  const CustomerCartRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerCartScreen();
  }
}

class CustomerCheckoutRoute extends GoRouteData {
  const CustomerCheckoutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomerCheckoutScreen();
  }
}
