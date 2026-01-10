import 'package:cleer/domain/models/auth_identity/auth_identity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  // Initial state while checking auth status
  const factory AuthState.unknown() = Unknown;

  // State when a user is successfully signed in
  const factory AuthState.signedIn({required AuthIdentity? identity}) = SignedIn;

  // State when the user is signed out
  const factory AuthState.signedOut() = SignedOut;

  // State for when the user's session has expired
  const factory AuthState.sessionExpired({String? message}) = SessionExpired;

  // State for when a user's account has been deleted
  const factory AuthState.userDeleted() = UserDeleted;
}

extension AuthStateExtension on AuthState {
  bool get isAuthenticated => switch (this) {
    SignedIn() => true,
    _ => false,
  };
}
