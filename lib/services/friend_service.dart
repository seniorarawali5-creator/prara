import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:prashant/models/friend_request_model.dart';
import 'package:prashant/models/user_model.dart';

final logger = Logger();
final supabase = Supabase.instance.client;

class FriendService {
  /// Get list of accepted friends
  static Future<List<AppUser>> getFriends(String userId) async {
    try {
      logger.i('👥 Fetching friends for: $userId');

      // Get all friend requests where status is 'accepted' (both directions)
      final acceptedRequests = await supabase
          .from('friend_requests')
          .select()
          .or('senderId.eq.$userId,receiverId.eq.$userId')
          .eq('status', 'accepted');

      final friendIds = <String>[];
      for (final req in acceptedRequests) {
        if (req['senderId'] == userId) {
          friendIds.add(req['receiverId']);
        } else {
          friendIds.add(req['senderId']);
        }
      }

      if (friendIds.isEmpty) {
        logger.i('ℹ️ No friends found');
        return [];
      }

      // Fetch user data for all friends
      final friends = await supabase
          .from('users')
          .select()
          .inFilter('id', friendIds);

      logger.i('✅ Fetched ${friends.length} friends');
      return friends.map((u) => AppUser.fromJson(u)).toList();
    } catch (e) {
      logger.e('❌ Error fetching friends: $e');
      return [];
    }
  }

  /// Get friend requests received by the user
  static Future<List<FriendRequest>> getPendingRequests(String userId) async {
    try {
      logger.i('📬 Fetching pending requests for: $userId');

      final requests = await supabase
          .from('friend_requests')
          .select()
          .eq('receiverId', userId)
          .eq('status', 'pending');

      logger.i('✅ Fetched ${requests.length} pending requests');
      return requests.map((r) => FriendRequest.fromJson(r)).toList();
    } catch (e) {
      logger.e('❌ Error fetching requests: $e');
      return [];
    }
  }

  /// Send a friend request
  static Future<bool> sendFriendRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      logger.i('📤 Sending friend request from $senderId to $receiverId');

      // Check if request already exists
      final existing = await supabase
          .from('friend_requests')
          .select()
          .or('senderId.eq.$senderId,receiverId.eq.$receiverId')
          .or('senderId.eq.$receiverId,receiverId.eq.$senderId');

      if (existing.isNotEmpty) {
        logger.w('⚠️ Friend request already exists');
        return false;
      }

      await supabase.from('friend_requests').insert({
        'senderId': senderId,
        'receiverId': receiverId,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      logger.i('✅ Friend request sent');
      return true;
    } catch (e) {
      logger.e('❌ Error sending request: $e');
      return false;
    }
  }

  /// Accept a friend request
  static Future<bool> acceptFriendRequest(String requestId) async {
    try {
      logger.i('✅ Accepting friend request: $requestId');

      await supabase.from('friend_requests').update({
        'status': 'accepted',
        'respondedAt': DateTime.now().toIso8601String(),
      }).eq('id', requestId);

      logger.i('✅ Friend request accepted');
      return true;
    } catch (e) {
      logger.e('❌ Error accepting request: $e');
      return false;
    }
  }

  /// Reject a friend request
  static Future<bool> rejectFriendRequest(String requestId) async {
    try {
      logger.i('❌ Rejecting friend request: $requestId');

      await supabase.from('friend_requests').update({
        'status': 'rejected',
        'respondedAt': DateTime.now().toIso8601String(),
      }).eq('id', requestId);

      logger.i('✅ Friend request rejected');
      return true;
    } catch (e) {
      logger.e('❌ Error rejecting request: $e');
      return false;
    }
  }

  /// Get user profile by ID
  static Future<AppUser?> getUserProfile(String userId) async {
    try {
      logger.i('👤 Fetching profile for: $userId');

      final user = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (user != null) {
        logger.i('✅ Profile fetched');
        return AppUser.fromJson(user);
      }
      return null;
    } catch (e) {
      logger.e('❌ Error fetching profile: $e');
      return null;
    }
  }

  /// Get user's stories
  static Future<List<Map<String, dynamic>>> getUserStories(String userId) async {
    try {
      logger.i('📖 Fetching stories for: $userId');

      final stories = await supabase
          .from('stories')
          .select()
          .eq('userId', userId)
          .order('createdAt', ascending: false);

      logger.i('✅ Fetched ${stories.length} stories');
      return stories;
    } catch (e) {
      logger.e('❌ Error fetching stories: $e');
      return [];
    }
  }

  /// Check if two users are friends
  static Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final request = await supabase
          .from('friend_requests')
          .select()
          .or('senderId.eq.$userId1,receiverId.eq.$userId1')
          .or('senderId.eq.$userId2,receiverId.eq.$userId2')
          .eq('status', 'accepted');

      return request.isNotEmpty;
    } catch (e) {
      logger.e('❌ Error checking friend status: $e');
      return false;
    }
  }

  /// Get user's display name with online status
  static Future<Map<String, dynamic>?> getUserStatusInfo(String userId) async {
    try {
      final user = await supabase
          .from('users')
          .select('id, fullName, isOnline, profilePhotoUrl')
          .eq('id', userId)
          .single();

      return user;
    } catch (e) {
      logger.e('❌ Error fetching user status: $e');
      return null;
    }
  }
}
