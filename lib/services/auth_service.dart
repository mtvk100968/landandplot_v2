// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/user_model.dart';
import './user_service.dart';

/// Phones that should become admin automatically (optional)
const _bypassPhones = [
  '+19999999999',
  '+18888888888',
  '+17777777777',
  '9959788005'
];

const _adminPhones = {'+919959788005', '+19999999999'};

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _userService = UserService();

  // -------- DEBUG LOGGER --------
  void _logAuthError(FirebaseAuthException e, {StackTrace? st}) {
    debugPrint('🔴 FirebaseAuthException');
    debugPrint('  • code: ${e.code}');
    debugPrint('  • message: ${e.message}');
    debugPrint('  • email: ${e.email}');
    debugPrint('  • credential: ${e.credential}');
    final dyn = e as dynamic;
    for (final k in ['plugin', 'tenantId', 'phoneAuthCredential', 'details']) {
      try {
        debugPrint('  • $k: ${dyn.$k}');
      } catch (_) {}
    }
    if (e.stackTrace != null) {
      debugPrintStack(stackTrace: e.stackTrace, label: '  • e.stackTrace');
    }
    if (st != null) {
      debugPrintStack(stackTrace: st, label: '  • caught stackTrace');
    }
  }
  // --------------------------------

  /// Public: start phone auth, trigger callbacks
  Future<void> signInWithPhoneNumber(
    String phoneNumber,
    Function(String verificationId) codeSent,
    Function(FirebaseAuthException) verificationFailed,
  ) async {
    debugPrint('🔔 verifyPhoneNumber() phone=$phoneNumber');

    try {
      await _auth
          .verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ verificationCompleted (auto sign-in).');
          try {
            await signInWithPhoneAuthCredential(credential);
          } catch (e, st) {
            debugPrint('❌ auto sign-in save failed: $e');
            debugPrintStack(stackTrace: st);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('  • raw toString(): $e');
          try {
            debugPrint('  • details map: ${(e as dynamic).details}');
          } catch (_) {}
          _logAuthError(e);
          verificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(
              '✉️ codeSent verId=$verificationId resendToken=$resendToken');
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⌛ codeAutoRetrievalTimeout verId=$verificationId');
        },
      )
          .catchError((error, st) {
        debugPrint('🔥 verifyPhoneNumber FUTURE error: $error');
        if (error is PlatformException) {
          debugPrint('  • platform code: ${error.code}');
          debugPrint('  • platform message: ${error.message}');
          debugPrint('  • platform details: ${error.details}');
        }
        debugPrintStack(stackTrace: st);
        if (error is FirebaseAuthException) {
          _logAuthError(error, st: st);
          verificationFailed(error);
        }
      });
    } catch (err, st) {
      if (err is FirebaseAuthException) {
        _logAuthError(err, st: st);
        verificationFailed(err);
      } else {
        debugPrint('⚠️ NON-FirebaseAuth error in verifyPhoneNumber: $err');
        debugPrintStack(stackTrace: st);
        rethrow;
      }
    }
  }

  /// Public: complete sign-in with credential. Decides role internally.
  Future<User?> signInWithPhoneAuthCredential(
    PhoneAuthCredential phoneAuthCredential,
  ) async {
    final authResult = await _auth.signInWithCredential(phoneAuthCredential);
    final user = authResult.user;
    if (user == null) return null;

    await _ensureUserDoc(user);
    return user;
  }

  Future<void> signOut() async => _auth.signOut();

  User? getCurrentUser() => _auth.currentUser;

  // ---------- Helpers ----------

  Future<void> _ensureUserDoc(User user) async {
    final existing = await _userService.getUserById(user.uid);
    final phone = user.phoneNumber ?? '';

    if (existing != null) {
      // Just ensure role (admins list) if needed, but DON'T blank fields
      final forcedRole =
          _adminPhones.contains(phone) ? 'admin' : existing.userType;
      if (forcedRole != existing.userType) {
        await _userService.updateUser(existing.copyWith(userType: forcedRole));
      }
      return; // ← stop here, do NOT re-save with nulls
    }

    // New user: create
    final role = _adminPhones.contains(phone) ? 'admin' : 'user';
    await _userService.saveUser(AppUser(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      phoneNumber: phone,
      userType: role,
    ));
  }
}
