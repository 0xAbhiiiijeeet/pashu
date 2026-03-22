import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Shown as a modal bottom sheet when the user hasn't completed onboarding.
/// On successful name registration, morphs into a success confirmation view
/// and auto-dismisses after 2 seconds.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   isDismissible: false,
///   enableDrag: false,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const NameBottomSheet(),
/// );
/// ```
class NameBottomSheet extends StatefulWidget {
  const NameBottomSheet({super.key});

  @override
  State<NameBottomSheet> createState() => _NameBottomSheetState();
}

class _NameBottomSheetState extends State<NameBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isDone = false;
  String _registeredName = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isButtonEnabled = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onEnter() async {
    if (!_isButtonEnabled) return;
    
    // Prevent double submission
    if (_isDone) return;
    
    final name = _nameController.text.trim();
    final authProvider = context.read<AuthProvider>();
    
    // Check if already loading
    if (authProvider.isLoading) return;
    
    final success = await authProvider.completeOnboarding(name);
    if (!mounted) return;
    if (success) {
      setState(() {
        _isDone = true;
        _registeredName = name;
      });
      // Auto-dismiss after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Unable to complete registration. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: _isDone ? _buildSuccess() : _buildInput(),
    );
  }

  // ── Input view ─────────────────────────────────────────────────────────────
  Widget _buildInput() {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      key: const ValueKey('input'),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text(
                l10n.isHindi
                    ? 'मुझे आपको क्या बुलाना चाहिए भाई?'
                    : 'What should I call you brother?',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Center(
              child: Text(
                l10n.isHindi ? 'मुझे अपना नाम बताएं' : 'Tell me your name',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8F8F8F),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Name input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                width: double.infinity,
                height: 66,
                clipBehavior: Clip.antiAlias,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset.zero,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.isHindi ? 'नाम बताएं' : 'Tell me name',
                      hintStyle: const TextStyle(
                        color: Color(0xFF909090),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Enter button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Consumer<AuthProvider>(
                builder: (_, auth, __) {
                  final isLoading = auth.isLoading;
                  return GestureDetector(
                    onTap: _isButtonEnabled && !isLoading ? _onEnter : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 66,
                      decoration: BoxDecoration(
                        gradient: _isButtonEnabled
                            ? const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF838967),
                                  Color(0xFF21231A),
                                ],
                              )
                            : null,
                        color:
                            _isButtonEnabled ? null : const Color(0x9B838967),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              l10n.isHindi ? 'दर्ज करें' : 'Enter',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Success view ───────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('success'),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Image.asset(
            'assets/images/onboarding_check.png',
            width: 39,
            height: 39,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.isHindi
                  ? '$_registeredName जी, आपका नाम दर्ज हो गया है!'
                  : '$_registeredName ji, your name has been registered!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
