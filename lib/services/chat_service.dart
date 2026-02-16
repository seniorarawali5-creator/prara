import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prashant/models/chat_message_model.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

final logger = Logger();
const uuid = Uuid();
final supabase = Supabase.instance.client;

abstract class ChatService {
  Future<List<ChatMessage>> getDirectMessages(String userId, String peerId);
  Future<List<ChatMessage>> getGroupMessages(String groupId);
  Future<void> sendMessage(ChatMessage message);
  Future<void> sendGroupMessage(ChatMessage message, String groupId);
  Future<void> markAsRead(String messageId);
  Future<List<ChatMessage>> searchMessages(String query, String userId);
  Stream<List<ChatMessage>> getDirectMessagesStream(String userId, String peerId);
  Stream<List<ChatMessage>> getGroupMessagesStream(String groupId);
}

class ChatServiceImpl implements ChatService {
  @override
  Future<List<ChatMessage>> getDirectMessages(
      String userId, String peerId) async {
    try {
      logger.i('📨 Fetching direct messages between $userId and $peerId');
      
      final chatId = _generateChatId(userId, peerId);
      final messages = await supabase
          .from('messages')
          .select()
          .eq('chatId', chatId)
          .order('createdAt', ascending: false)
          .limit(50);

      logger.i('✅ Found ${messages.length} messages');
      return (messages as List)
          .map((msg) => ChatMessage.fromJson({...msg}))
          .toList();
    } catch (e) {
      logger.e('❌ Get direct messages error: $e');
      return [];
    }
  }

  @override
  Future<List<ChatMessage>> getGroupMessages(String groupId) async {
    try {
      logger.i('👥 Fetching group messages for: $groupId');
      
      final messages = await supabase
          .from('messages')
          .select()
          .eq('groupId', groupId)
          .order('createdAt', ascending: false)
          .limit(50);

      logger.i('✅ Found ${messages.length} group messages');
      return (messages as List)
          .map((msg) => ChatMessage.fromJson({...msg}))
          .toList();
    } catch (e) {
      logger.e('❌ Get group messages error: $e');
      return [];
    }
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    try {
      logger.i('✉️ Sending message from ${message.senderId}');
      
      final chatId = message.chatId ?? _generateChatId(message.senderId, message.receiverId ?? '');
      
      await supabase.from('messages').insert({
        'id': uuid.v4(),
        'chatId': chatId,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'text': message.text,
        'isRead': false,
        'attachmentURL': message.attachmentURL,
        'createdAt': DateTime.now().toIso8601String(),
      });

      logger.i('✅ Message sent successfully');
    } catch (e) {
      logger.e('❌ Send message error: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendGroupMessage(ChatMessage message, String groupId) async {
    try {
      logger.i('✉️ Sending group message to: $groupId');
      
      await supabase.from('messages').insert({
        'id': uuid.v4(),
        'groupId': groupId,
        'senderId': message.senderId,
        'text': message.text,
        'isRead': false,
        'attachmentURL': message.attachmentURL,
        'createdAt': DateTime.now().toIso8601String(),
      });

      logger.i('✅ Group message sent successfully');
    } catch (e) {
      logger.e('❌ Send group message error: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      logger.i('👁️ Marking message as read: $messageId');
      await supabase
          .from('messages')
          .update({'isRead': true})
          .eq('id', messageId);
      logger.i('✅ Message marked as read');
    } catch (e) {
      logger.e('❌ Mark as read error: $e');
    }
  }

  @override
  Future<List<ChatMessage>> searchMessages(String query, String userId) async {
    try {
      logger.i('🔍 Searching messages for: $query');
      
      final messages = await supabase
          .from('messages')
          .select()
          .or('senderId.eq.$userId,receiverId.eq.$userId')
          .ilike('text', '%$query%')
          .limit(20);

      logger.i('✅ Found ${messages.length} search results');
      return (messages as List)
          .map((msg) => ChatMessage.fromJson({...msg}))
          .toList();
    } catch (e) {
      logger.e('❌ Search messages error: $e');
      return [];
    }
  }

  @override
  Stream<List<ChatMessage>> getDirectMessagesStream(
      String userId, String peerId) {
    try {
      logger.i('📡 Setting up stream for direct messages');
      
      final chatId = _generateChatId(userId, peerId);
      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chatId', chatId)
          .order('createdAt', ascending: false)
          .map((messages) => (messages as List)
              .map((msg) => ChatMessage.fromJson({...msg}))
              .toList());
    } catch (e) {
      logger.e('❌ Direct messages stream error: $e');
      return Stream.value([]);
    }
  }

  @override
  Stream<List<ChatMessage>> getGroupMessagesStream(String groupId) {
    try {
      logger.i('📡 Setting up stream for group messages: $groupId');
      
      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('groupId', groupId)
          .order('createdAt', ascending: false)
          .map((messages) => (messages as List)
              .map((msg) => ChatMessage.fromJson({...msg}))
              .toList());
    } catch (e) {
      logger.e('❌ Group messages stream error: $e');
      return Stream.value([]);
    }
  }

  String _generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }
}

