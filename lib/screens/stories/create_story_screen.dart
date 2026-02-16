import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:prashant/services/permission_service.dart';

final logger = Logger();

class CreateStoryScreen extends StatefulWidget {
  final String userId;
  const CreateStoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  late TextEditingController _captionController;
  File? _selectedMedia;
  String _mediaType = 'image'; // 'image' or 'video'
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedMedia = File(pickedFile.path);
          _mediaType = 'image';
        });
        _videoController?.dispose();
        _videoController = null;
        logger.i('✅ Image selected: ${pickedFile.name}');
      }
    } catch (e) {
      logger.e('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _pickVideo() async {
    try {
      // Request permissions first
      final hasPermission = await PermissionService.requestMediaPermissions();
      if (!hasPermission) {
        Get.snackbar('Permission Denied', 'Please enable camera/photo permissions in settings',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60), // Max 60 seconds
      );

      if (pickedFile != null) {
        setState(() {
          _selectedMedia = File(pickedFile.path);
          _mediaType = 'video';
        });
        
        // Initialize video controller for preview
        _videoController = VideoPlayerController.file(_selectedMedia!)
          ..initialize().then((_) {
            setState(() {});
          });
        
        logger.i('✅ Video selected: ${pickedFile.name}');
      }
    } catch (e) {
      logger.e('Error picking video: $e');
      Get.snackbar('Error', 'Failed to pick video: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<String?> _uploadMediaToSupabase() async {
    if (_selectedMedia == null) return null;

    try {
      final supabase = Supabase.instance.client;
      final fileExtension = _mediaType == 'video' ? 'mp4' : 'jpg';
      final fileName = 'stories/${widget.userId}/${_mediaType}/${const Uuid().v4()}.$fileExtension';

      logger.i('📤 Uploading $_mediaType to: $fileName');

      await supabase.storage.from('stories').upload(
            fileName,
            _selectedMedia!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = supabase.storage.from('stories').getPublicUrl(fileName);
      logger.i('✅ $_mediaType uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      logger.e('Upload error: $e');
      Get.snackbar('Upload Error', 'Failed to upload $_mediaType: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  Future<void> _publishStory() async {
    if (_selectedMedia == null) {
      Get.snackbar('Error', 'Please select an image or video',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload media first
      final mediaUrl = await _uploadMediaToSupabase();
      
      if (mediaUrl == null) {
        Get.snackbar('Error', 'Failed to upload $_mediaType',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final supabase = Supabase.instance.client;
      final expiresAt = DateTime.now().add(const Duration(hours: 24));

      await supabase.from('stories').insert({
        'id': const Uuid().v4(),
        'userId': widget.userId,
        'imageURL': mediaUrl,
        'caption': _captionController.text.isNotEmpty ? _captionController.text : null,
        'views': 0,
        'mediaType': _mediaType, // 'image' or 'video'
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      });

      logger.i('✅ Story published successfully');
      Get.back();
      Get.snackbar('Success', 'Story published! (expires in 24 hours)',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      logger.e('Publish error: $e');
      Get.snackbar('Error', 'Failed to publish story: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Story'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _selectedMedia == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No image selected',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : (_mediaType == 'image'
                      ? Image.file(
                          _selectedMedia!,
                          fit: BoxFit.cover,
                        )
                      : VideoPlayer(_videoController!)),
            ),
            const SizedBox(height: 12),

            // Pick image button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Select Image from Gallery'),
              ),
            ),
            const SizedBox(height: 24),

            // Caption
            const Text(
              'Caption (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              maxLines: 4,
              maxLength: 500,
              enabled: !_isSaving,
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
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
            const SizedBox(height: 24),

            // Info
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
                      'Stories expire in 24 hours and images are uploaded to secure cloud storage',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Publish button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _publishStory,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.publish),
                label: Text(_isSaving ? 'Publishing...' : 'Publish Story'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
