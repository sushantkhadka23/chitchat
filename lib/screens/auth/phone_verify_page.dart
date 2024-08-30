import 'package:chitchat/services/alert_service.dart';
import 'package:chitchat/services/auth_service.dart';
import 'package:chitchat/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:toastification/toastification.dart';

class PhoneVerifyScreen extends StatefulWidget {
  final String phoneNumber;
  const PhoneVerifyScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  final TextEditingController _pinController = TextEditingController();

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _authService = _getIt.get<AuthService>();
  }

  void _verifyCode(BuildContext context) async {
    String smsCode = _pinController.text.trim();
    if (smsCode.length == 6) {
      try {
        bool verify = await _authService.verifyOtp(smsCode: smsCode);
        if (verify) {
          _alertService.showToast(
            title: 'Success',
            description: 'Your phone number has been verified.',
            type: ToastificationType.success,
          );
          _navigationService.pushNamed('/register');
        } else {
          _alertService.showToast(
            title: 'Failed',
            description: 'Failed to verify the code. Please try again.',
            type: ToastificationType.error,
          );
        }
      } catch (e) {
        _alertService.showToast(
          title: 'Error',
          description:
              'An error occurred while verifying the code. Please try again.',
          type: ToastificationType.warning,
        );
      }
    }
  }

  Future<void> _resendCode() async {
    try {
      await _authService.resendCode(
        phoneNumber: widget.phoneNumber,
        codeAutoRetrievalTimeout: (String verificationId) {},
        verificationFailed: (e) {
          _alertService.showToast(
            title: 'Code Resend Failed!',
            description: 'Resend Verification Failed: ${e.message}',
            type: ToastificationType.error,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _alertService.showToast(
            title: 'Code Resend',
            description: 'Code Resent to ${widget.phoneNumber}',
            type: ToastificationType.info,
          );
        },
      );
    } catch (e) {
      _alertService.showToast(
        title: 'Error',
        description:
            'An error occurred while verifying the code. Please try again.',
        type: ToastificationType.warning,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backButton(theme),
                SizedBox(height: mediaSize.height * 0.04),
                _headerText(theme),
                SizedBox(height: mediaSize.height * 0.04),
                _otpForm(theme),
                SizedBox(height: mediaSize.height * 0.024),
                _verifyButton(theme),
                SizedBox(height: mediaSize.height * 0.016),
                _notifyText(theme),
                SizedBox(height: mediaSize.height * 0.016),
                _resendButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _backButton(ColorScheme theme) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: theme.onSurface,
      ),
      onPressed: () {
        _navigationService.pushNamed('index');
      },
    );
  }

  Widget _headerText(ColorScheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Code',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please enter the 6-digit code sent to your phone',
          style: TextStyle(
            fontSize: 16,
            color: theme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _otpForm(ColorScheme theme) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        fieldHeight: 50,
        fieldWidth: 50,
        activeFillColor: theme.surface,
        inactiveFillColor: theme.surface.withOpacity(0.7),
        selectedFillColor: theme.surface,
        activeColor: theme.primary,
        inactiveColor: theme.primary.withOpacity(0.5),
        selectedColor: theme.primary,
      ),
      animationDuration: const Duration(milliseconds: 300),
      controller: _pinController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.length != 6) {
          return 'Please enter a valid 6-digit code';
        }
        return null;
      },
    );
  }

  Widget _verifyButton(ColorScheme theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _verifyCode(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Verify Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.surface,
          ),
        ),
      ),
    );
  }

  Widget _notifyText(ColorScheme theme) {
    return Center(
      child: Text(
        "Didn't receive code?",
        style: TextStyle(
          color: theme.onSurface,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _resendButton(ColorScheme theme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _resendCode();
        },
        style: TextButton.styleFrom(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Resend Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
      ),
    );
  }
}
