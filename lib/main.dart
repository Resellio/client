import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/routes/auth_routes.dart' as auth_routes;
import 'package:resellio/routes/customer_routes.dart';
import 'package:resellio/routes/organizer_routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final cubit = context.watch<AuthCubit>();

        final router = GoRouter(
          routes: [
            ...auth_routes.$appRoutes,
            if (cubit.isCustomer) $customerShellRouteData,
            if (cubit.isOrganizer) $organizerShellRouteData,
          ],
          redirect: (context, state) {
            if (!cubit.isAuthenticated) {
              return const auth_routes.LoginRoute().location;
            }

            if (cubit.isOrganizerRegistrationNeeded) {
              return const auth_routes.OrganizerRegistrationRoute().location;
            }

            return null;
          },
        );

        return MaterialApp.router(
          routerConfig: router,
          title: 'Bilety na wydarzenia | Resellio',
          theme: ThemeData(
            fontFamily: 'Roboto',
            primarySwatch: Colors.blue,
          ),
        );
      },
    );
  }
}
