import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  User? _user;

  User? get user {
    return _user;
  }

  AuthService() {
    _auth.authStateChanges().listen(authStateChangeStreamListener);
  }

  void authStateChangeStreamListener(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }

  Future<void> phoneNumberVerification({
    required String phoneNumber,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) async {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> verifyOtp({
    required String smsCode,
  }) async {
    if (_verificationId != null) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode,
        );
        await _auth.signInWithCredential(credential);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> resendCode({
    required String phoneNumber,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
