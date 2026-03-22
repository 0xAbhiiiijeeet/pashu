import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _isButtonEnabled = _phoneController.text.length == 10;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_isProcessing) return; // Prevent double tap
    
    setState(() => _isProcessing = true);
    
    final authProvider = context.read<AuthProvider>();
    debugPrint('📱 Sending OTP to: ${_phoneController.text.trim()}');
    final success = await authProvider.sendOtp(_phoneController.text.trim());
    debugPrint('📱 OTP send result: $success');
    
    if (!mounted) return;
    
    setState(() => _isProcessing = false);
    
    if (success) {
      debugPrint('📱 Navigating to OTP screen...');
      Navigator.pushNamed(
        context,
        RouteNames.otp,
        arguments: {'phoneNumber': _phoneController.text.trim()},
      );
    } else {
      debugPrint('❌ OTP send failed: ${authProvider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Unable to send OTP. Please check your number and try again.'),
        ),
      );
    }
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
                      SizedBox(height: size.height * 0.22),

                      // Glassmorphic card (title + subtitle inside)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: const AuthCard(
                          title: TextSpan(
                            children: [
                              TextSpan(
                                text: 'PashuMitra ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: "your pet's\nfitness partner",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          subtitle:
                              'Enter your number to get answers to all your animal related questions.',
                        ),
                      ),

                      SizedBox(height: size.height * 0.025),

                      // Fields outside the card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: Column(
                          children: [
                            AuthPhoneInputRow(controller: _phoneController),
                            const SizedBox(height: 16),
                            AuthContinueButton(
                              isEnabled: _isButtonEnabled && !_isProcessing,
                              onTap: _onContinue,
                            ),
                            const SizedBox(height: 12),
                            const AuthTrustedBadge(),
                          ],
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
