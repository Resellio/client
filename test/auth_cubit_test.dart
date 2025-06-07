/*import 'package:bloc_test/bloc_test.dart';
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
  // --- Constants for Test Data ---
  const mockAccessToken = 'mock-access-token';
  const mockToken = 'mock-token';
  const newToken = 'new-token';
  const testEmail = 'test@example.com';
  const testFirstName = 'John';
  const testLastName = 'Doe';
  const testDisplayName = 'JohnD';

  // --- Test Models ---
  const tCustomer = Customer(email: testEmail, token: mockToken);
  const tOrganizer = Organizer(
    email: testEmail,
    token: mockToken,
    firstName: testFirstName,
    lastName: testLastName,
    displayName: testDisplayName,
  );
  const tNewlyRegisteredOrganizer = Organizer(
    email: testEmail,
    token: newToken,
    firstName: testFirstName,
    lastName: testLastName,
    displayName: testDisplayName,
  );
  const tOrganizerRegistrationNeeded =
      OrganizerRegistrationNeeded(email: testEmail, token: mockToken);

  // --- Expected States ---
  const tUnauthorizedState = Unauthorized();
  const tAuthorizedCustomerState = AuthorizedCustomer(tCustomer);
  const tAuthorizedOrganizerState = AuthorizedOrganizer(tOrganizer);
  const tAuthorizedOrganizerRegNeededState =
      AuthorizedOrganizerRegistrationNeeded(tOrganizerRegistrationNeeded);
  const tAuthorizedUnverifiedOrganizerState =
      AuthorizedUnverifiedOrganizer(tOrganizer);
  const tAuthorizedUnverifiedOrganizerAfterRegState =
      AuthorizedUnverifiedOrganizer(tNewlyRegisteredOrganizer);

  // --- Mocks ---
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

    reset(mockApiService);
    reset(mockGoogleSignIn);
    reset(mockGoogleAccount);
    reset(mockGoogleAuth);

    when(() => mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleAccount);
    when(() => mockGoogleAccount.authentication)
        .thenAnswer((_) async => mockGoogleAuth);
    when(() => mockGoogleAuth.accessToken).thenReturn(mockAccessToken);
    when(() => mockGoogleAccount.email).thenReturn(testEmail);
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
      expect(authCubit.state, tUnauthorizedState);
    });

    group('customerSignInWithGoogle', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthorizedCustomer] when sign in and API call succeed',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.customerGoogleLogin,
            ),
          ).thenAnswer((_) async => {'token': mockToken});
          return authCubit;
        },
        act: (cubit) => cubit.customerSignInWithGoogle(),
        expect: () => [tAuthorizedCustomerState],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.customerGoogleLogin,
            ),
          ).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when Google Sign-In is cancelled (returns null)',
        build: () {
          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
          return authCubit;
        },
        act: (cubit) => cubit.customerSignInWithGoogle(),
        expect: () => <AuthState>[],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verifyNever(
            () => mockApiService.googleLogin(
              accessToken: any(named: 'accessToken'),
              endpoint: any(named: 'endpoint'),
            ),
          );
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when API call fails',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.customerGoogleLogin,
            ),
          ).thenThrow(Exception('API Error'));
          return authCubit;
        },
        act: (cubit) => cubit.customerSignInWithGoogle(),
        expect: () => <AuthState>[],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.customerGoogleLogin,
            ),
          ).called(1);
        },
      );
    });

    group('organizerSignInWithGoogle', () {
      void setupMockOrganizerAboutMe({required bool isVerified}) {
        when(() => mockApiService.organizerAboutMe(token: mockToken))
            .thenAnswer(
          (_) async => {
            'email': testEmail,
            'firstName': testFirstName,
            'lastName': testLastName,
            'displayName': testDisplayName,
            'isVerified': isVerified,
          },
        );
      }

      blocTest<AuthCubit, AuthState>(
        'emits [AuthorizedOrganizer] when organizer is verified',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': mockToken,
              'isVerified': true,
              'isNewOrganizer': false,
            },
          );
          setupMockOrganizerAboutMe(isVerified: true);
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => [tAuthorizedOrganizerState],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).called(1);
          verify(() => mockApiService.organizerAboutMe(token: mockToken))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthorizedOrganizerRegistrationNeeded] when organizer is new',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': mockToken,
              'isVerified': false,
              'isNewOrganizer': true,
            },
          );
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => [tAuthorizedOrganizerRegNeededState],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).called(1);
          verifyNever(
            () => mockApiService.organizerAboutMe(token: any(named: 'token')),
          );
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthorizedUnverifiedOrganizer] when organizer exists but is unverified',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': mockToken,
              'isVerified': false,
              'isNewOrganizer': false,
            },
          );
          setupMockOrganizerAboutMe(isVerified: false);
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => [tAuthorizedUnverifiedOrganizerState],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).called(1);
          verify(() => mockApiService.organizerAboutMe(token: mockToken))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when Google Sign-In is cancelled (returns null)',
        build: () {
          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => <AuthState>[],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verifyNever(
            () => mockApiService.googleLogin(
              accessToken: any(named: 'accessToken'),
              endpoint: any(named: 'endpoint'),
            ),
          );
          verifyNever(
            () => mockApiService.organizerAboutMe(token: any(named: 'token')),
          );
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when API login call fails',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenThrow(Exception('API Login Error'));
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => <AuthState>[],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).called(1);
          verifyNever(
            () => mockApiService.organizerAboutMe(token: any(named: 'token')),
          );
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when API aboutMe call fails (for verified/unverified cases)',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': mockToken,
              'isVerified': false,
              'isNewOrganizer': false,
            },
          );
          when(() => mockApiService.organizerAboutMe(token: mockToken))
              .thenThrow(Exception('API AboutMe Error'));
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => <AuthState>[],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).called(1);
          verify(() => mockApiService.organizerAboutMe(token: mockToken))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing when organizerAboutMe returns incomplete data',
        build: () {
          when(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).thenAnswer(
            (_) async => {
              'token': mockToken,
              'isVerified': false,
              'isNewOrganizer': false,
            },
          );
          when(() => mockApiService.organizerAboutMe(token: mockToken))
              .thenAnswer(
            (_) async => {'email': testEmail},
          );
          return authCubit;
        },
        act: (cubit) => cubit.organizerSignInWithGoogle(),
        expect: () => <AuthState>[],
        verify: (_) {
          verify(() => mockGoogleSignIn.signIn()).called(1);
          verify(
            () => mockApiService.googleLogin(
              accessToken: mockAccessToken,
              endpoint: ApiEndpoints.organizerGoogleLogin,
            ),
          ).called(1);
          verify(() => mockApiService.organizerAboutMe(token: mockToken))
              .called(1);
        },
      );
    });

    group('completeOrganizerRegistration', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthorizedUnverifiedOrganizer] when registration completes successfully',
        build: () {
          authCubit.emit(tAuthorizedOrganizerRegNeededState);
          when(
            () => mockApiService.createOrganizer(
              token: mockToken,
              firstName: testFirstName,
              lastName: testLastName,
              displayName: testDisplayName,
            ),
          ).thenAnswer(
            (_) async => {'token': newToken},
          );
          return authCubit;
        },
        act: (cubit) => cubit.completeOrganizerRegistration(
          firstName: testFirstName,
          lastName: testLastName,
          displayName: testDisplayName,
        ),
        expect: () => [tAuthorizedUnverifiedOrganizerAfterRegState],
        verify: (_) {
          verify(
            () => mockApiService.createOrganizer(
              token: mockToken,
              firstName: testFirstName,
              lastName: testLastName,
              displayName: testDisplayName,
            ),
          ).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits nothing and stays in [AuthorizedOrganizerRegistrationNeeded] if API call fails',
        build: () {
          authCubit.emit(tAuthorizedOrganizerRegNeededState);
          when(
            () => mockApiService.createOrganizer(
              token: mockToken,
              firstName: testFirstName,
              lastName: testLastName,
              displayName: testDisplayName,
            ),
          ).thenThrow(Exception('API Create Error'));
          return authCubit;
        },
        act: (cubit) => cubit.completeOrganizerRegistration(
          firstName: testFirstName,
          lastName: testLastName,
          displayName: testDisplayName,
        ),
        expect: () => <AuthState>[],
        verify: (_) {
          verify(
            () => mockApiService.createOrganizer(
              token: mockToken,
              firstName: testFirstName,
              lastName: testLastName,
              displayName: testDisplayName,
            ),
          ).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing if state is not [AuthorizedOrganizerRegistrationNeeded]',
        build: () {
          authCubit.emit(tUnauthorizedState);
          return authCubit;
        },
        act: (cubit) => cubit.completeOrganizerRegistration(
          firstName: testFirstName,
          lastName: testLastName,
          displayName: testDisplayName,
        ),
        expect: () => <AuthState>[],
        verify: (_) {
          verifyNever(
            () => mockApiService.createOrganizer(
              token: any(named: 'token'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
              displayName: any(named: 'displayName'),
            ),
          );
        },
      );
    });

    group('logout', () {
      <String, AuthState>{
        'AuthorizedCustomer': tAuthorizedCustomerState,
        'AuthorizedOrganizer': tAuthorizedOrganizerState,
        'AuthorizedUnverifiedOrganizer': tAuthorizedUnverifiedOrganizerState,
        'AuthorizedOrganizerRegistrationNeeded':
            tAuthorizedOrganizerRegNeededState,
      }.forEach((stateName, initialState) {
        blocTest<AuthCubit, AuthState>(
          'emits [Unauthorized] when logging out from $stateName',
          build: () {
            authCubit.emit(initialState);
            return authCubit;
          },
          act: (cubit) => cubit.logout(),
          expect: () => [tUnauthorizedState],
          verify: (_) {
            verify(() => mockGoogleSignIn.signOut()).called(1);
            verify(() => HydratedBloc.storage.delete('AuthCubit')).called(1);
          },
        );
      });
    });
  });
}
*/
