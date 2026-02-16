import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      Get.snackbar('Error', 'New passwords do not match',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      Get.snackbar('Error', 'New password must be at least 6 characters',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      Get.snackbar('Error', 'New password must be different from current password',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // First, verify current password by re-authenticating
      logger.i('🔐 Verifying current password...');
      try {
        await supabase.auth.signInWithPassword(
          email: user.email!,
          password: _currentPasswordController.text,
        );
      } catch (e) {
        Get.snackbar('Error', 'Current password is incorrect',
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() => _isLoading = false);
        return;
      }

      // Update password
      logger.i('🔄 Updating password...');
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      logger.i('✅ Password changed successfully');
      Get.snackbar('Success', 'Password changed successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);

      // Clear fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      logger.e('Error changing password: $e');
      Get.snackbar('Error', 'Failed to change password: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: const Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For security, you\'ll need your current password to set a new one',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Current Password
            _buildPasswordField(
              'Current Password',
              'Enter your current password',
              _currentPasswordController,
              _isCurrentPasswordVisible,
              (value) => setState(() => _isCurrentPasswordVisible = value),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 20),

            // New Password
            _buildPasswordField(
              'New Password',
              'Create a strong new password',
              _newPasswordController,
              _isNewPasswordVisible,
              (value) => setState(() => _isNewPasswordVisible = value),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 20),

            // Confirm Password
            _buildPasswordField(
              'Confirm New Password',
              'Re-enter your new password',
              _confirmPasswordController,
              _isConfirmPasswordVisible,
              (value) => setState(() => _isConfirmPasswordVisible = value),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),

            // Password Requirements
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password Requirements:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement(
                    _newPasswordController.text.length >= 6,
                    'At least 6 characters',
                  ),
                  _buildRequirement(
                    _newPasswordController.text != _currentPasswordController.text,
                    'Different from current password',
                  ),
                  _buildRequirement(
                    _newPasswordController.text == _confirmPasswordController.text &&
                        _newPasswordController.text.isNotEmpty,
                    'Passwords match',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Security Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔒 Security Tips:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Use a unique password\n• Avoid common words or names\n• Mix uppercase, lowercase, numbers',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    String hint,
    TextEditingController controller,
    bool isVisible,
    Function(bool) onVisibilityToggle, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: GestureDetector(
              onTap: enabled ? () => onVisibilityToggle(!isVisible) : null,
              child: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: enabled ? Colors.grey : Colors.grey.shade400,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(bool isMet, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? Colors.green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
