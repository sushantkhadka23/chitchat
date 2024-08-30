import 'package:chitchat/screens/auth/phone_verify_page.dart';
import 'package:chitchat/services/auth_service.dart';
import 'package:chitchat/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class PhoneSigninPage extends StatefulWidget {
  const PhoneSigninPage({super.key});

  @override
  State<PhoneSigninPage> createState() => _PhoneSigninPageState();
}

class _PhoneSigninPageState extends State<PhoneSigninPage> {
  final _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PhoneNumber? _phoneNumber;

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  Future<void> _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      String fullPhoneNumber = _phoneNumber!.completeNumber;
      await _authService.phoneNumberVerification(phoneNumber: fullPhoneNumber);
      _navigationService.push(
        MaterialPageRoute(
          builder: (context) => PhoneVerifyScreen(phoneNumber: fullPhoneNumber),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/undraw_mobile_login_re_9ntv.svg',
                  width: mediaSize.width * 0.8,
                ),
                SizedBox(height: mediaSize.height * 0.03),
                const Text(
                  "Phone Verification",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: mediaSize.height * 0.01),
                const Text(
                  "We need to register your phone before getting started!",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      IntlPhoneField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        initialCountryCode: 'NP',
                        onChanged: (phone) {
                          setState(() {
                            _phoneNumber = phone;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: mediaSize.height * 0.01),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    minimumSize: Size(
                      double.infinity,
                      mediaSize.height * 0.067,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _sendVerificationCode,
                  child: const Text(
                    "Send Verification Code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
