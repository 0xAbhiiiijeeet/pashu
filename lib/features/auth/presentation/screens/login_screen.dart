import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/settings_provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchSettings();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final phoneNumber = _phoneController.text.trim();
    final settingsProvider = context.read<SettingsProvider>();
    final authProvider = context.read<AuthProvider>();

    await settingsProvider.forceRefresh();
    final isBypass = settingsProvider.isOtpBypassed;

    if (!mounted) return;

    if (isBypass) {
      debugPrint('OTP bypass enabled. Logging in directly...');
      final success = await authProvider.verifyOtp(phoneNumber, '123456');

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.home,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ??
                  'Unable to login right now. Please try again.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = false);

    debugPrint('Navigating to OTP screen...');
    Navigator.pushNamed(
      context,
      RouteNames.otp,
      arguments: {'phoneNumber': phoneNumber},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const ColoredBox(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: AuthAppBar(),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(child: AuthBackground()),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.22),
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
