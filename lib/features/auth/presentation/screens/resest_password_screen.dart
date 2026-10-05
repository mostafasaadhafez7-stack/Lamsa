import 'dart:async';
import 'package:final_project/core/utils/validators.dart';
import 'package:final_project/core/theme/app_colors.dart';
import 'package:final_project/core/theme/app_styles.dart';
import 'package:final_project/core/widgets/custom_elevated_buttom.dart';
import 'package:final_project/core/widgets/custom_text_button.dart';
import 'package:final_project/core/widgets/custom_text_field.dart';
import 'package:final_project/features/auth/presentation/auth_cubit/auth_cubit.dart';
import 'package:final_project/features/auth/presentation/auth_cubit/auth_states.dart';
import 'package:final_project/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:final_project/features/auth/presentation/widgets/password_text_section.dart';
import 'package:final_project/features/auth/presentation/widgets/custom_password_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.email = ""});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> myKey = GlobalKey();
  final TextEditingController otpCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();
  final TextEditingController confirmPasswordCtl = TextEditingController();

  bool isVisiablePassword = true;
  bool isVisiableConfirmPassword = true;

  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining <= 0) {
        t.cancel();
      } else {
        if (mounted) {
          setState(() => _secondsRemaining--);
        }
      }
    });
  }

  String get _formattedTime {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpCtl.dispose();
    passwordCtl.dispose();
    confirmPasswordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundClr,
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is ResetPasswordSuccessState) {
                _timer?.cancel();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset successfully! Please sign in with your new password.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              } else if (state is ResetPasswordFailureState) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is ResendOtpSuccessState) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A new OTP has been sent to your email.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ResendOtpFailureState) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is ResetPasswordLoadingState;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: myKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.bottomBackgroundClr,
                            side: BorderSide(color: AppColors.grayClr),
                          ),
                          icon: const Icon(Icons.arrow_back, size: 20),
                        ),
                        const SizedBox(height: 24),

                        const PasswordTextSection(
                          title: "Reset Password",
                          subtitle:
                              "Please enter the OTP sent to your email and your new password.",
                        ),
                        if (widget.email.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.email,
                            style: AppStyles.style14Bold.copyWith(
                              fontFamily: "Manrope",
                              color: AppColors.primaryClr,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // OTP Code Input
                        CustomTextField(
                          controller: otpCtl,
                          title: 'Verification Code (OTP)',
                          hintText: 'Enter 6-digit code',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(
                            Icons.numbers,
                            color: AppColors.grayClr,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the verification code';
                            }
                            if (value.trim().length < 4) {
                              return 'Please enter a valid OTP';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Resend OTP Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _secondsRemaining > 0
                                  ? "Resend code in $_formattedTime"
                                  : "Didn't receive code?",
                              style: AppStyles.style13Regular.copyWith(
                                color: AppColors.grayClr,
                              ),
                            ),
                            CustomTextButton(
                              text: state is ResendOtpLoadingState
                                  ? "Sending..."
                                  : "Resend Code",
                              onPressed: _secondsRemaining == 0 && widget.email.isNotEmpty
                                  ? () {
                                      _startTimer();
                                      context.read<AuthCubit>().resendOtp(
                                            email: widget.email,
                                          );
                                    }
                                  : null,
                              textClr: _secondsRemaining == 0
                                  ? AppColors.primaryClr
                                  : AppColors.grayClr,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        CustomPasswordField(
                          controller: passwordCtl,
                          title: 'New Password',
                          hintText: 'Please enter your new password',
                          validator: (password) {
                            return Validator.validatePassword(password ?? '');
                          },
                          obscureText: isVisiablePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisiablePassword = !isVisiablePassword;
                              });
                            },
                            icon: Icon(
                              isVisiablePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.grayClr,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomPasswordField(
                          controller: confirmPasswordCtl,
                          title: 'Confirm New Password',
                          hintText: 'Please confirm your new password',
                          obscureText: isVisiableConfirmPassword,
                          validator: (confirmPassword) {
                            return Validator.validateConfirmPassword(
                              passwordCtl.text,
                              confirmPassword ?? '',
                            );
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisiableConfirmPassword =
                                    !isVisiableConfirmPassword;
                              });
                            },
                            icon: Icon(
                              isVisiableConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.grayClr,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        CustomElevatedButton(
                          text: isLoading ? "Resetting Password..." : "Reset Password",
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (!myKey.currentState!.validate()) return;
                                  context.read<AuthCubit>().resetPassword(
                                        email: widget.email,
                                        otp: otpCtl.text.trim(),
                                        newPassword: passwordCtl.text,
                                      );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
