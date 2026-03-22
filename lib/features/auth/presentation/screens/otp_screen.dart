import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isProcessing = false;

  static const int _resendSeconds = 28;
  int _secondsRemaining = _resendSeconds;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() {
      setState(() {
        _isButtonEnabled = _otpController.text.length == 6;
      });
    });
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = _resendSeconds;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_isProcessing) return; // Prevent double tap
    
    setState(() => _isProcessing = true);
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(
      widget.phoneNumber,
      _otpController.text.trim(),
    );
    
    if (!mounted) return;
    
    setState(() => _isProcessing = false);

    if (success) {
      // Pop all screens and let _AuthGate show HomeScreen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Unable to verify OTP. Please enter the correct OTP.'),
        ),
      );
    }
  }

  Future<void> _onResend() async {
    if (_isProcessing) return; // Prevent double tap during resend
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp(widget.phoneNumber);
    if (mounted) {
      if (success) {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Unable to resend OTP. Please try again in a moment.'),
          ),
        );
      }
    }
  }

  String get _displayPhone {
    final raw = widget.phoneNumber;
    if (raw.length == 10) {
      return '+91 ${raw.substring(0, 5)} ${raw.substring(5)}';
    }
    return '+91 $raw';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── AppBar with status bar SafeArea (solid primary colour)
          const ColoredBox(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: AuthAppBar(),
            ),
          ),

          // ── Background image + scrollable content below the AppBar
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(child: AuthBackground()),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.20),

                      // Glassmorphic card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: const AuthCard(
                          title: TextSpan(
                            text: "PashuMitra your pet's fitness partner",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          subtitle: 'Enter the 6-digit OTP',
                        ),
                      ),

                      SizedBox(height: size.height * 0.025),

                      // Info text + phone number
                      const Text(
                        'We have sent you a 6-digit verification code.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _displayPhone,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // OTP input
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: AuthOtpInputField(controller: _otpController),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Continue button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: AuthContinueButton(
                          isEnabled: _isButtonEnabled && !_isProcessing,
                          onTap: _onContinue,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Resend row
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                        ),
                        child: AuthOtpResendRow(
                          canResend: _canResend,
                          secondsRemaining: _secondsRemaining,
                          onResend: _onResend,
                          onChangeNumber: () =>
                              Navigator.of(context).maybePop(),
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),
                      const AuthFooter(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
