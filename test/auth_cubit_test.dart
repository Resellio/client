import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/model/Users/customer.dart';
import 'package:resellio/features/common/model/Users/organizer.dart';
import 'package:resellio/features/common/model/Users/organizer_registration_needed.dart';

// Mocks
class MockApiService extends Mock implements ApiService {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockStorage extends Mock implements Storage {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void setupHydratedStorage() {
  HydratedBloc.storage = MockStorage();
  when(() => HydratedBloc.storage.read(any())).thenAnswer((_) async => null);
  when(() => HydratedBloc.storage.write(any(), any<dynamic>()))
      .thenAnswer((_) async {});
  when(() => HydratedBloc.storage.clear()).thenAnswer((_) async {});
  when(() => HydratedBloc.storage.delete(any())).thenAnswer((_) async {});
}

void main() {
  late AuthCubit authCubit;
  late MockApiService mockApiService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleAccount;
  late MockGoogleSignInAuthentication mockGoogleAuth;

  setUpAll(setupHydratedStorage);

  setUp(() {
    mockApiService = MockApiService();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleAccount = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();

    // Setup common mock behaviors
    when(() => mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleAccount);
    when(() => mockGoogleAccount.authentication)
        .thenAnswer((_) async => mockGoogleAuth);
    when(() => mockGoogleAuth.accessToken).thenReturn('mock-access-token');
    when(() => mockGoogleAccount.email).thenReturn('test@example.com');
    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

    authCubit = AuthCubit(
      apiService: mockApiService,
      googleSignIn: mockGoogleSignIn,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is Unauthorized', () {
      expect(authCubit.state, const Unauthorized());
    });

    group('customerSignInWithGoogle', () {
      blocTest<AuthCubit, AuthState>(
        'emits AuthorizedCustomer when sign in succeeds',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: 'mock-access-token',
              endpoint: ApiEndpoints.customerGoogleLogin,
            ),
          ).thenAnswer((_) async => {'token': 'mock-token'});
          return authCubit;
        },
        act: (cubit) => cubit.customerSignInWithGoogle(),
        expect: () => [
          const AuthorizedCustomer(
            Customer(email: 'test@example.com', token: 'mock-token'),
          ),
        ],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: 'mock-access-token',
              endpoint: ApiEndpoints.customerGoogleLogin,
            ),
          ).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when sign in fails',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: 'mock-access-token',
              endpoint: ApiEndpoints.customerGoogleLogin,
            ),
          ).thenThrow(Exception('API Error'));
          return authCubit;
        },
        act: (cubit) => cubit.customerSignInWithGoogle(),
        expect: () => <AuthState>[],
      );
    });

    group('organizerSignInWithGoogle', () {
      blocTest<AuthCubit, AuthState>(
        'emits AuthorizedOrganizer when organizer is verified',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: 'mock-access-token',
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': 'mock-token',
              'isVerified': true,
              'isNewOrganizer': false,
            },
          );
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => [
          const AuthorizedOrganizer(
            Organizer(
              email: 'test@example.com',
              token: 'mock-token',
              firstName: 'John',
              lastName: 'Doe',
              displayName: 'JohnD',
            ),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthorizedOrganizerRegistrationNeeded when organizer is new',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: 'mock-access-token',
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': 'mock-token',
              'isVerified': false,
              'isNewOrganizer': true,
            },
          );
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => [
          const AuthorizedOrganizerRegistrationNeeded(
            OrganizerRegistrationNeeded(
              email: 'test@example.com',
              token: 'mock-token',
            ),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthorizedUnverifiedOrganizer when organizer is unverified',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: 'mock-access-token',
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': 'mock-token',
              'isVerified': false,
              'isNewOrganizer': false,
            },
          );
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => [
          const AuthorizedUnverifiedOrganizer(
            Organizer(
              email: 'test@example.com',
              token: 'mock-token',
              firstName: 'John',
              lastName: 'Doe',
              displayName: 'JohnD',
            ),
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when sign in fails',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: 'mock-access-token',
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenThrow(Exception('API Error'));
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => <AuthState>[],
      );
    });

    group('completeOrganizerRegistration', () {
      blocTest<AuthCubit, AuthState>(
        'emits AuthorizedUnverifiedOrganizer when registration completes',
        build: () {
          authCubit.emit(
            const AuthorizedOrganizerRegistrationNeeded(
              OrganizerRegistrationNeeded(
                email: 'test@example.com',
                token: 'mock-token',
              ),
            ),
          );
          when(
            () => mockApiService.createOrganizer(
              token: 'mock-token',
              firstName: 'John',
              lastName: 'Doe',
              displayName: 'JohnD',
            ),
          ).thenAnswer((_) async => {'token': 'new-token'});
          return authCubit;
        },
        act: (cubit) => cubit.completeOrganizerRegistration(
          firstName: 'John',
          lastName: 'Doe',
          displayName: 'JohnD',
        ),
        expect: () => [
          const AuthorizedUnverifiedOrganizer(
            Organizer(
              email: 'test@example.com',
              token: 'new-token',
              firstName: 'John',
              lastName: 'Doe',
              displayName: 'JohnD',
            ),
          ),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits Unauthorized when logging out as customer',
        build: () {
          authCubit.emit(
            const AuthorizedCustomer(
              Customer(email: 'test@example.com', token: 'mock-token'),
            ),
          );
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [const Unauthorized()],
        verify: (_) {
          verify(() => mockGoogleSignIn.signOut()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits Unauthorized when logging out as organizer',
        build: () {
          authCubit.emit(
            const AuthorizedOrganizer(
              Organizer(
                email: 'test@example.com',
                token: 'mock-token',
                firstName: 'John',
                lastName: 'Doe',
                displayName: 'JohnD',
              ),
            ),
          );
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [const Unauthorized()],
        verify: (_) {
          verify(() => mockGoogleSignIn.signOut()).called(1);
        },
      );
    });
  });
}
