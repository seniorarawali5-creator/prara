import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:prashant/models/user_model.dart';
import 'package:prashant/services/auth_service.dart';
import 'package:prashant/services/permission_service.dart';

final logger = Logger();

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthServiceImpl();
  final ImagePicker _imagePicker = ImagePicker();
  
  late TextEditingController _fullNameController;
  late TextEditingController _mobileController;
  late TextEditingController _bioController;
  
  File? _selectedProfileImage;
  bool _isSaving = false;
  bool _isDarkMode = false;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _mobileController = TextEditingController();
    _bioController = TextEditingController();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _fullNameController.text = user.fullName;
          _mobileController.text = user.mobileNumber;
          _bioController.text = user.bio ?? '';
          _isDarkMode = user.isDarkMode;
        });
      }
    } catch (e) {
      logger.e('Error loading user: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      // Request permissions first
      final hasPermission = await PermissionService.requestPhotosPermission();
      if (!hasPermission) {
        Get.snackbar('Permission Denied', 'Please enable photo permissions in settings',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        setState(() => _selectedProfileImage = File(pickedFile.path));
        logger.i('✅ Profile image selected');
      }
    } catch (e) {
      logger.e('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedProfileImage == null) return null;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final fileName = 'profiles/$userId/profile.jpg';
      logger.i('📤 Uploading profile image...');

      await supabase.storage.from('profiles').upload(
            fileName,
            _selectedProfileImage!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = supabase.storage.from('profiles').getPublicUrl(fileName);
      logger.i('✅ Profile image uploaded');
      return publicUrl;
    } catch (e) {
      logger.e('Upload error: $e');
      Get.snackbar('Upload Error', 'Failed to upload profile image: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your full name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? profilePhotoUrl = _currentUser?.profilePhotoUrl;
      
      // Upload new profile image if selected
      if (_selectedProfileImage != null) {
        final uploadedUrl = await _uploadProfileImage();
        if (uploadedUrl != null) {
          profilePhotoUrl = uploadedUrl;
        }
      }

      final updatedUser = AppUser(
        id: _currentUser!.id,
        email: _currentUser!.email,
        fullName: _fullNameController.text,
        mobileNumber: _mobileController.text,
        role: _currentUser!.role,
        profilePhotoUrl: profilePhotoUrl,
        bio: _bioController.text,
        isDarkMode: _isDarkMode,
        createdAt: _currentUser!.createdAt,
        isOnline: _currentUser!.isOnline,
      );

      await _authService.updateProfile(updatedUser);
      
      logger.i('✅ Profile updated successfully');
      Get.snackbar('Success', 'Profile updated successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } catch (e) {
      logger.e('Error saving profile: $e');
      Get.snackbar('Error', 'Failed to save profile: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Photo
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _selectedProfileImage != null
                      ? ClipOval(
                          child: Image.file(
                            _selectedProfileImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _currentUser?.profilePhotoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _currentUser!.profilePhotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.person,
                                        size: 60,
                                        color: Colors.grey.shade400),
                              ),
                            )
                          : Icon(Icons.person,
                              size: 60, color: Colors.grey.shade400),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isSaving ? null : _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Full Name
            _buildTextField(
              'Full Name',
              'Enter your full name',
              Icons.person_outline,
              _fullNameController,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),

            // Email (read-only)
            TextField(
              enabled: false,
              controller: TextEditingController(text: _currentUser?.email ?? ''),
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Your email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mobile Number
            _buildTextField(
              'Mobile Number',
              'Enter your mobile number',
              Icons.phone_outlined,
              _mobileController,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),

            // Bio
            _buildTextField(
              'Bio',
              'Tell us about yourself...',
              Icons.description_outlined,
              _bioController,
              maxLines: 4,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 24),

            // Dark Mode Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode,
                          color: Color(0xFF6366F1).withOpacity(0.6)),
                      const SizedBox(width: 12),
                      const Text('Dark Mode',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Switch(
                    value: _isDarkMode,
                    onChanged: _isSaving
                        ? null
                        : (value) => setState(() => _isDarkMode = value),
                    activeColor: const Color(0xFF6366F1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isSaving
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
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
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
}
