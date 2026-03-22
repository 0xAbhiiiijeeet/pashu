import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _verificationId;
  int? _resendToken;

  /// Send OTP to phone number using Firebase
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function() onAutoVerified,
  }) async {
    try {
      debugPrint('📱 Sending Firebase OTP to: $phoneNumber');
      
      // Format phone number with country code if not present
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // India country code
      }
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        
        // Auto-verification (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Auto-verification completed');
          onAutoVerified();
        },
        
        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.code} - ${e.message}');
          String errorMessage;
          
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later';
              break;
            case 'app-not-authorized':
            case 'invalid-app-credential':
              errorMessage = 'App verification failed. Please contact support.';
              debugPrint('⚠️ Firebase app not authorized - check SHA fingerprints in Firebase Console');
              break;
            case 'web-context-cancelled':
              errorMessage = 'Verification cancelled. Please try again.';
              break;
            default:
              errorMessage = e.message ?? 'Verification failed';
          }
          
          onError(errorMessage);
        },
        
        // Code sent successfully
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ OTP sent successfully');
          debugPrint('📱 Verification ID: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ Auto-retrieval timeout');
          _verificationId = verificationId;
        },
        
        // For resending OTP
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      onError(e.toString());
    }
  }

  /// Verify OTP and get Firebase ID token
  Future<String?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      debugPrint('🔐 Verifying OTP...');
      
      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Get ID token
      final idToken = await userCredential.user?.getIdToken();
      
      debugPrint('✅ OTP verified successfully');
      debugPrint('🔑 ID Token obtained');
      
      return idToken;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ OTP verification failed: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP. Please try again';
          break;
        case 'session-expired':
          errorMessage = 'OTP expired. Please request a new one';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      throw Exception('Unable to verify OTP. Please check your OTP and try again.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Firebase sign out successful');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
    }
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}
