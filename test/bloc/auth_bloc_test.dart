import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Example AuthState
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final Map<String, dynamic> user;

  const AuthSuccess({required this.token, required this.user});

  @override
  List<Object?> get props => [token, user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Example AuthEvent
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

// Mock AuthRemoteDataSource
class MockAuthRemoteDataSource {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (email == 'test@example.com' && password == 'password123') {
      return {
        'success': true,
        'token': 'test_token',
        'user': {'_id': '123', 'email': 'test@example.com', 'role': 'customer'},
      };
    } else if (email == 'error@example.com') {
      throw Exception('Network error');
    } else {
      return {
        'success': false,
        'message': 'Invalid credentials',
      };
    }
  }
}

// Example AuthBloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MockAuthRemoteDataSource _authRemoteDataSource;

  AuthBloc({required MockAuthRemoteDataSource authRemoteDataSource})
      : _authRemoteDataSource = authRemoteDataSource,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRemoteDataSource.login(
        event.email,
        event.password,
      );

      if (result != null && result['success'] == true) {
        emit(AuthSuccess(
          token: result['token'],
          user: result['user'],
        ));
      } else {
        emit(AuthFailure(
          message: result?['message'] ?? 'Login failed',
        ));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }
}

void main() {
  group('AuthBloc', () {
    late MockAuthRemoteDataSource mockAuthRemoteDataSource;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRemoteDataSource = MockAuthRemoteDataSource();
      authBloc = AuthBloc(authRemoteDataSource: mockAuthRemoteDataSource);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('LoginRequested', () {
      const email = 'test@example.com';
      const password = 'password123';
      const token = 'test_token';
      const user = {'_id': '123', 'email': 'test@example.com', 'role': 'customer'};

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when login is successful',
        build: () => authBloc,
        act: (bloc) => bloc.add(const LoginRequested(email: email, password: password)),
        expect: () => [
          isA<AuthLoading>(),
          const AuthSuccess(token: token, user: user),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails',
        build: () => authBloc,
        act: (bloc) => bloc.add(const LoginRequested(email: 'wrong@example.com', password: 'wrong')),
        expect: () => [
          isA<AuthLoading>(),
          const AuthFailure(message: 'Invalid credentials'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login throws exception',
        build: () => authBloc,
        act: (bloc) => bloc.add(const LoginRequested(email: 'error@example.com', password: 'password')),
        expect: () => [
          isA<AuthLoading>(),
          const AuthFailure(message: 'Exception: Network error'),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthInitial] when logout is requested',
        build: () => authBloc,
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [isA<AuthInitial>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthInitial] when logout is requested from success state',
        build: () => authBloc,
        seed: () => const AuthSuccess(token: 'token', user: {'_id': '123'}),
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [isA<AuthInitial>()],
      );
    });

    group('Multiple Events', () {
      blocTest<AuthBloc, AuthState>(
        'handles multiple login attempts correctly',
        build: () => authBloc,
        act: (bloc) {
          bloc.add(const LoginRequested(email: 'test@example.com', password: 'password123'));
          bloc.add(const LoginRequested(email: 'wrong@example.com', password: 'wrong'));
        },
        expect: () => [
          isA<AuthLoading>(),
          const AuthSuccess(token: 'test_token', user: {'_id': '123', 'email': 'test@example.com', 'role': 'customer'}),
          isA<AuthLoading>(),
          const AuthFailure(message: 'Invalid credentials'),
        ],
      );
    });

    group('State Transitions', () {
      test('transitions from initial to loading to success', () async {
        expect(authBloc.state, isA<AuthInitial>());
        
        authBloc.add(const LoginRequested(email: 'test@example.com', password: 'password123'));
        
        await expectLater(
          authBloc.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            const AuthSuccess(token: 'test_token', user: {'_id': '123', 'email': 'test@example.com', 'role': 'customer'}),
          ]),
        );
      });

      test('transitions from initial to loading to failure', () async {
        expect(authBloc.state, isA<AuthInitial>());
        
        authBloc.add(const LoginRequested(email: 'wrong@example.com', password: 'wrong'));
        
        await expectLater(
          authBloc.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            const AuthFailure(message: 'Invalid credentials'),
          ]),
        );
      });
    });
  });
} 