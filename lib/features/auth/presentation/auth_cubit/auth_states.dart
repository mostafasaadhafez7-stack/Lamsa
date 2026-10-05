abstract class AuthState {}

class AuthInitialState extends AuthState {}

class LoginLoadingState extends AuthState {}

class LoginSuccessState extends AuthState {}

class LoginFailureState extends AuthState {
  final String error;
  LoginFailureState({required this.error});
}

class SignUpLoadingState extends AuthState {}

class SignUpSuccessState extends AuthState {}

class SignUpFailureState extends AuthState {}

//
// Verify Email States - El_Shafei
class VerifyEmailLoadingState extends AuthState {}

class VerifyEmailSuccessState extends AuthState {}

class VerifyEmailFailureState extends AuthState {
  final String error;
  VerifyEmailFailureState({required this.error});
}

// Change Password States
class ChangePasswordLoadingState extends AuthState {}

class ChangePasswordSuccessState extends AuthState {}

class ChangePasswordFailureState extends AuthState {
  final String error;
  ChangePasswordFailureState({required this.error});
}

// Resed Password States
class ResendOtpLoadingState extends AuthState {}

class ResendOtpSuccessState extends AuthState {}

class ResendOtpFailureState extends AuthState {
  final String error;
  ResendOtpFailureState(this.error);
}

class UnverifiedAccountState extends AuthState {
  final String email;
  UnverifiedAccountState(this.email);
}

// Forgot Password States
class ForgotPasswordLoadingState extends AuthState {}

class ForgotPasswordSuccessState extends AuthState {}

class ForgotPasswordFailureState extends AuthState {
  final String error;
  ForgotPasswordFailureState({required this.error});
}

// Reset Password States
class ResetPasswordLoadingState extends AuthState {}

class ResetPasswordSuccessState extends AuthState {}

class ResetPasswordFailureState extends AuthState {
  final String error;
  ResetPasswordFailureState({required this.error});
}

// Profile States
class GetProfileLoadingState extends AuthState {}

class GetProfileSuccessState extends AuthState {
  final Map<String, dynamic> user;
  GetProfileSuccessState({required this.user});
}

class GetProfileFailureState extends AuthState {
  final String error;
  GetProfileFailureState({required this.error});
}

// Logout States
class LogoutLoadingState extends AuthState {}

class LogoutSuccessState extends AuthState {}

