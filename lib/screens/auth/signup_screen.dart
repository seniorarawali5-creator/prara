import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prashant/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'dart:async';

final logger = Logger();

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _emailController;
  late TextEditingController _otpController;
  bool _otpSent = false;
  bool _isLoading = false;
  final AuthService _authService = AuthServiceImpl();
  int _otpCountdown = 0;
  Timer? _otpTimer;
  String? _sentEmail;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_emailController.text.isEmpty) {
      Get.snackbar('Error', 'Email enter karo',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      Get.snackbar('Error', 'Valid email enter karo',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendOTP(_emailController.text.trim());
      setState(() {
        _otpSent = true;
        _sentEmail = _emailController.text.trim();
        _otpCountdown = 59;
      });
      _startOTPCountdown();
      Get.snackbar('Success', 'OTP bhej diya gya! Email check karo',
          backgroundColor: Colors.green, colorText: Colors.white);
      logger.i('OTP sent to ${_emailController.text}');
    } catch (e) {
      logger.e('OTP send error: $e');
      Get.snackbar('Error', 'OTP bhejne mein error: ${e.toString().substring(0, 60)}',
          backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 3));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startOTPCountdown() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _otpCountdown -= 1);
        if (_otpCountdown <= 0) {
          _otpTimer?.cancel();
        }
      }
    });
  }

  Future<void> _verifyOTPAndSignup() async {
    if (_otpController.text.isEmpty) {
      Get.snackbar('Error', 'OTP enter karo',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.verifyOTPAndSignup(_sentEmail ?? '', _otpController.text.trim());
      Get.snackbar('Success', 'Account banaya gya! Welcome 🎉',
          backgroundColor: Colors.green, colorText: Colors.white);
      logger.i('✅ Signup successful with OTP');
      Get.offNamed('/home');
    } catch (e) {
      logger.e('OTP verification error: $e');
      String errorMsg = 'OTP verification fail';
      if (e.toString().contains('invalid')) {
        errorMsg = 'OTP wrong hai. Dobara try karo';
      } else if (e.toString().contains('expired')) {
        errorMsg = 'OTP expire ho gya. Naya OTP request karo';
        setState(() => _otpSent = false);
      }
      Get.snackbar('Error', errorMsg,
          backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 3));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join Prashant to boost your productivity',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Email or OTP section
              if (!_otpSent) ...[
                // Email Input
                const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ] else ...[
                // OTP Verification Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OTP bhej diya gya: $_sentEmail',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Email ke inbox me check karo',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // OTP Input
                const Text('OTP Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_otpCountdown > 0)
                  Text(
                    'OTP expire hoga ${_otpCountdown}s me',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                const SizedBox(height: 32),

                // Verify OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTPAndSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Verify OTP & Sign Up',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Resend OTP
                if (_otpCountdown <= 0)
                  Center(
                    child: GestureDetector(
                      onTap: _sendOTP,
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 32),

              // Login Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text('Login', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
