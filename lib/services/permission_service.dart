import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class PermissionService {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      logger.i('📷 Requesting camera permission...');
      final status = await Permission.camera.request();
      
      if (status.isDenied) {
        logger.w('❌ Camera permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        logger.w('⚠️ Camera permission permanently denied - opening app settings');
        openAppSettings();
        return false;
      }
      
      logger.i('✅ Camera permission granted');
      return true;
    } catch (e) {
      logger.e('Error requesting camera permission: $e');
      return false;
    }
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      logger.i('💾 Requesting storage permission...');
      final status = await Permission.storage.request();
      
      if (status.isDenied) {
        logger.w('❌ Storage permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        logger.w('⚠️ Storage permission permanently denied - opening app settings');
        openAppSettings();
        return false;
      }
      
      logger.i('✅ Storage permission granted');
      return true;
    } catch (e) {
      logger.e('Error requesting storage permission: $e');
      return false;
    }
  }

  // Request photos permission
  static Future<bool> requestPhotosPermission() async {
    try {
      logger.i('📸 Requesting photos permission...');
      final status = await Permission.photos.request();
      
      if (status.isDenied) {
        logger.w('❌ Photos permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        logger.w('⚠️ Photos permission permanently denied');
        openAppSettings();
        return false;
      }
      
      logger.i('✅ Photos permission granted');
      return true;
    } catch (e) {
      logger.e('Error requesting photos permission: $e');
      return false;
    }
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      logger.i('🔔 Requesting notification permission...');
      final status = await Permission.notification.request();
      
      if (status.isDenied) {
        logger.w('❌ Notification permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        logger.w('⚠️ Notification permission permanently denied');
        openAppSettings();
        return false;
      }
      
      logger.i('✅ Notification permission granted');
      return true;
    } catch (e) {
      logger.e('Error requesting notification permission: $e');
      return false;
    }
  }

  // Request all permissions at once
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    try {
      logger.i('📋 Requesting all permissions...');
      final statuses = await [
        Permission.camera,
        Permission.photos,
        Permission.notification,
        Permission.storage,
      ].request();
      
      logger.i('✅ All permissions requested');
      return statuses;
    } catch (e) {
      logger.e('Error requesting all permissions: $e');
      return {};
    }
  }

  // Check if permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      logger.e('Error checking permission: $e');
      return false;
    }
  }

  // Request media permissions (camera + photos)
  static Future<bool> requestMediaPermissions() async {
    try {
      logger.i('📷 Requesting media permissions...');
      final cameraGranted = await requestCameraPermission();
      final photosGranted = await requestPhotosPermission();
      
      return cameraGranted || photosGranted;
    } catch (e) {
      logger.e('Error requesting media permissions: $e');
      return false;
    }
  }
}
