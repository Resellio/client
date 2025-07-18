import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/style/app_theme.dart';
import 'package:resellio/routes/admin_routes.dart';
import 'package:resellio/routes/auth_routes.dart' as auth_routes;
import 'package:resellio/routes/customer_routes.dart';
import 'package:resellio/routes/organizer_routes.dart';

GoRouter? _router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  await initializeDateFormatting('pl_PL');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();

    _authCubit = AuthCubit(
      googleSignIn: GoogleSignIn(),
    );

    _apiService = ApiService(
      baseUrl: ApiEndpoints.baseUrl,
      client: http.Client(),
      tokenProvider: () {
        try {
          return _authCubit.isAuthenticated ? _authCubit.token : null;
        } catch (err) {
          return null;
        }
      },
    );

    _authCubit.setApiService(_apiService);

    _router ??= _createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _apiService.client.close();
    super.dispose();
  }

  GoRouter _createRouter(AuthCubit authCubit) {
    return GoRouter(
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      initialLocation: const auth_routes.LoginRoute().location,
      routes: [
        ...auth_routes.$appRoutes,
        $customerShellRouteData,
        $organizerShellRouteData,
        $adminShellRouteData,
      ],
      redirect: (context, state) {
        debugPrint('[AuthState] ${authCubit.state.runtimeType}');
        final loggedIn = authCubit.isAuthenticated;

        final authRoutes = [
          const auth_routes.LoginRoute().location,
          const auth_routes.OrganizerRegistrationRoute().location,
          const auth_routes.OrganizerUnverifiedRoute().location,
        ];

        if (!loggedIn) {
          debugPrint('[Redirect] Not logged in, going to Login');
          return const auth_routes.LoginRoute().location;
        }

        // If user needs to register organizer profile
        if (authCubit.isOrganizerRegistrationNeeded) {
          debugPrint(
            '[Redirect] Needs Organizer Registration, going to Registration',
          );
          return const auth_routes.OrganizerRegistrationRoute().location;
        }

        // If user is an unverified organizer
        if (authCubit.isUnverifiedOrganizer) {
          debugPrint('[Redirect] Is Unverified Organizer, going to Pending');
          return const auth_routes.OrganizerUnverifiedRoute().location;
        }

        if (loggedIn) {
          // If user is authenticated and trying to access login/registration/pending,
          if (authRoutes.contains(state.matchedLocation)) {
            if (authCubit.isCustomer) {
              debugPrint(
                '[Redirect] Logged in Customer on auth page, going to Customer Home',
              );
              return const CustomerEventsRoute().location;
            } else if (authCubit.isOrganizer) {
              debugPrint(
                '[Redirect] Logged in Organizer on auth page, going to Organizer Home',
              );
              return const OrganizerHomeRoute().location;
            } else if (authCubit.isAdmin) {
              debugPrint(
                '[Redirect] Logged in Admin on auth page, going to Admin Home',
              );
              return const AdminHomeRoute().location;
            }
          }

          // If customer is trying to access organizer routes
          if (state.matchedLocation.startsWith('/org') &&
              authCubit.isCustomer) {
            debugPrint(
              '[Redirect] Customer trying to access Organizer routes, going to Customer Home',
            );
            return const CustomerEventsRoute().location;
          }

          // If organizer is trying to access customer routes
          if (state.matchedLocation.startsWith('/app') &&
              authCubit.isOrganizer) {
            debugPrint(
              '[Redirect] Organizer trying to access Customer routes, going to Organizer Home',
            );
            return const OrganizerHomeRoute().location;
          }

          // If non-admin is trying to access admin routes
          if (state.matchedLocation.startsWith('/admin') &&
              !authCubit.isAdmin) {
            debugPrint(
              '[Redirect] Non-admin trying to access Admin routes, redirecting to appropriate home',
            );
            if (authCubit.isCustomer) {
              return const CustomerEventsRoute().location;
            } else if (authCubit.isOrganizer) {
              return const OrganizerHomeRoute().location;
            }
          }
        }

        debugPrint(
          '[Redirect] No redirect needed for ${state.matchedLocation}',
        );
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.error}')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<AuthCubit>.value(
          value: _authCubit,
        ),
        Provider<ApiService>.value(
          value: _apiService,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        title: 'Bilety na wydarzenia | Resellio',
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _stream = stream;
    _subscription = _stream.listen((_) => notifyListeners());
  }

  late final Stream<dynamic> _stream;
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
