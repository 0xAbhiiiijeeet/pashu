import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background
// ─────────────────────────────────────────────────────────────────────────────

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/pashumitra_auth_bg.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────

class AuthAppBar extends StatelessWidget {
  const AuthAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Image.asset(
        'assets/images/pashu_mitra.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glassmorphic Card
// ─────────────────────────────────────────────────────────────────────────────

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.title, this.subtitle});

  final InlineSpan title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text.rich(title, textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Continue Button
// ─────────────────────────────────────────────────────────────────────────────

class AuthContinueButton extends StatelessWidget {
  const AuthContinueButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final isLoading = auth.isLoading;
        return GestureDetector(
          onTap: isEnabled && !isLoading ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: isEnabled ? const Color(0xFF535735) : const Color(0xB2938558),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _link('Terms'),
        _sep(),
        _link('Privacy'),
        _sep(),
        const Text(
          'Pashu Mitra Technologies',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _link(String label) => Text(
        label,
        style: const TextStyle(color: Color(0xFF959595), fontSize: 13),
      );

  Widget _sep() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(width: 1, height: 16, color: const Color(0xFF959595)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Trusted Badge
// ─────────────────────────────────────────────────────────────────────────────

class AuthTrustedBadge extends StatelessWidget {
  const AuthTrustedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
        SizedBox(width: 5),
        Text(
          'Trusted by 1 crore+ farmers',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone Input Row
// ─────────────────────────────────────────────────────────────────────────────

class AuthPhoneInputRow extends StatelessWidget {
  const AuthPhoneInputRow({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // +91 box
        Container(
          width: 73,
          height: 55,
          decoration: ShapeDecoration(
            color: AppColors.mintGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            '+91',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Phone number input — clean white container, no border stripe
        Expanded(
          child: Container(
            height: 55,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Enter your mobile number',
                hintStyle: TextStyle(color: Color(0xFF959595), fontSize: 15),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Input Field
// ─────────────────────────────────────────────────────────────────────────────

class AuthOtpInputField extends StatelessWidget {
  const AuthOtpInputField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            hintText: 'Enter OTP',
            hintStyle: TextStyle(
              color: Color(0xFF847E7E),
              fontSize: 18,
              letterSpacing: 0,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterText: '',
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Resend Row
// ─────────────────────────────────────────────────────────────────────────────

class AuthOtpResendRow extends StatelessWidget {
  const AuthOtpResendRow({
    super.key,
    required this.canResend,
    required this.secondsRemaining,
    required this.onResend,
    required this.onChangeNumber,
  });

  final bool canResend;
  final int secondsRemaining;
  final VoidCallback onResend;
  final VoidCallback onChangeNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: onChangeNumber,
            child: const Text(
              'change phone number',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3B3A3A),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ),
        Container(
          width: 1,
          height: 37,
          color: const Color(0xFF959595),
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        Flexible(
          child: GestureDetector(
            onTap: canResend ? onResend : null,
            child: Text(
              canResend
                  ? "Didn't receive OTP? Resend"
                  : "Resend (${secondsRemaining}s)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    canResend ? const Color(0xFF535735) : const Color(0xFF817E7D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.57,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
