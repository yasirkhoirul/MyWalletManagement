import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_auth/persentation/bloc/auth_bloc.dart';
import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/usecase/post_login.dart';
import 'package:module_auth/domain/usecase/post_logout.dart';
import 'package:module_auth/domain/usecase/post_signup.dart';
import 'package:module_auth/domain/usecase/listen_auth.dart';
import 'package:module_auth/domain/usecase/post_forgot_email.dart';

class MockPostLogin extends Mock implements PostLogin {}
class MockPostLogout extends Mock implements PostLogout {}
class MockPostSignup extends Mock implements PostSignup {}
class MockListenAuth extends Mock implements ListenAuth {}
class MockPostForgotEmail extends Mock implements PostForgotEmail {}

class FakeUser extends Fake implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  late MockPostLogin mockPostLogin;
  late MockPostLogout mockPostLogout;
  late MockPostSignup mockPostSignup;
  late MockListenAuth mockListenAuth;
  late MockPostForgotEmail mockPostForgotEmail;
  late AuthBloc bloc;

  setUp(() {
    mockPostLogin = MockPostLogin();
    mockPostLogout = MockPostLogout();
    mockPostSignup = MockPostSignup();
    mockListenAuth = MockListenAuth();
    mockPostForgotEmail = MockPostForgotEmail();

    when(() => mockListenAuth.execute()).thenAnswer((_) => const Stream.empty());

    bloc = AuthBloc(
      mockPostLogin,
      mockPostLogout,
      mockPostSignup,
      mockListenAuth,
      mockPostForgotEmail,
    );
  });

  tearDown(() {
    bloc.close();
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthSucces] when login succeeds',
    build: () {
      when(() => mockPostLogin.execute(any())).thenAnswer((_) async => 'Welcome user');
      return bloc;
    },
    act: (bloc) => bloc.add(AuthOnLogin(User('u', 'p'))),
    expect: () => [isA<AuthLoading>(), isA<AuthSucces>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthOnSendEmail] when forgot email succeeds',
    build: () {
      when(() => mockPostForgotEmail.execute(any())).thenAnswer((_) async {});
      return bloc;
    },
    act: (bloc) => bloc.add(AuthOnForgot('test@example.com')),
    expect: () => [isA<AuthLoading>(), isA<AuthOnSendEmail>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthLoading, AuthSucces] when signup succeeds (signup triggers login)',
    build: () {
      when(() => mockPostSignup.execute(any())).thenAnswer((_) async => 'Registered');
      when(() => mockPostLogin.execute(any())).thenAnswer((_) async => 'Welcome after signup');
      return bloc;
    },
    act: (bloc) => bloc.add(AuthOnSignUp(User('newuser', 'pass'))),
    expect: () => [isA<AuthLoading>(), isA<AuthLoading>(), isA<AuthSucces>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthInitial] when logout succeeds',
    build: () {
      when(() => mockPostLogout.execute()).thenAnswer((_) async {});
      return bloc;
    },
    act: (bloc) => bloc.add(AuthOnLogout()),
    expect: () => [isA<AuthLoading>(), isA<AuthInitial>()],
  );
}
