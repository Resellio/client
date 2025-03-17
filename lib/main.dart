import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/routes/auth_routes.dart';
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
        if (state is AuthLoading) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        final router = GoRouter(
          routes: [
            $loginRoute,
            if (context.watch<AuthCubit>().isCustomer) $customerShellRouteData,
            if (context.watch<AuthCubit>().isOrganizer)
              $organizerShellRouteData,
          ],
          redirect: (context, state) {
            if (!context.read<AuthCubit>().isAuthenticated) {
              return '/login';
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
