import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, String? email, String? error}) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  void _checkAuthStatus() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        email: session.user.email,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          email: session.user.email,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Please fill in all fields',
      );
      return;
    }

    if (password.length < 6) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Password must be at least 6 characters',
      );
      return;
    }

    try {
      await _supabase.auth.signUp(email: email, password: password);
      state = AuthState(
        status: AuthStatus.authenticated,
        email: email,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Sign up failed. Please try again.',
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Please fill in all fields',
      );
      return;
    }

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        email: email,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Login failed. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
