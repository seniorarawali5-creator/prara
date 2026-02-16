import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prashant/screens/auth/splash_screen.dart';
import 'package:prashant/screens/auth/login_options_screen.dart';
import 'package:prashant/screens/auth/login_screen.dart';
import 'package:prashant/screens/auth/signup_screen.dart';
import 'package:prashant/screens/auth/forgot_password_screen.dart';
import 'package:prashant/screens/auth/admin_login_screen.dart';
import 'package:prashant/screens/auth/admin_forgot_password_screen.dart';
import 'package:prashant/screens/auth/change_password_screen.dart';
import 'package:prashant/screens/main_navigation_screen.dart';
import 'package:prashant/screens/admin/admin_dashboard_screen.dart';
import 'package:prashant/screens/notes/create_note_screen.dart';
import 'package:prashant/screens/notes/note_detail_screen.dart';
import 'package:prashant/screens/stories/view_story_screen.dart';
import 'package:prashant/screens/stories/create_story_screen.dart';
import 'package:prashant/screens/chat/direct_chat_screen.dart';
import 'package:prashant/screens/chat/group_chat_screen.dart';
import 'package:prashant/screens/chat/new_chat_screen.dart';
import 'package:prashant/screens/settings/edit_profile_screen.dart';
import 'package:prashant/screens/friends/friend_profile_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String loginOptions = '/login_options';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot_password';
  static const String adminLogin = '/admin_login';
  static const String adminForgotPassword = '/admin_forgot_password';
  static const String home = '/home';
  static const String adminDashboard = '/admin_dashboard';
  
  // Placeholder routes
  static const String directChat = '/direct_chat';
  static const String groupChat = '/group_chat';
  static const String newChat = '/new_chat';
  static const String noteDetail = '/note_detail';
  static const String createNote = '/create_note';
  static const String viewStory = '/view_story';
  static const String createStory = '/create_story';
  static const String editProfile = '/edit_profile';
  static const String changePassword = '/change_password';
  static const String friendProfile = '/friend-profile';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: loginOptions,
      page: () => const LoginOptionsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: signup,
      page: () => const SignUpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: adminLogin,
      page: () => const AdminLoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: adminForgotPassword,
      page: () => const AdminForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardScreen(),
      transition: Transition.fadeIn,
    ),
    
    // Chat routes
    GetPage(
      name: directChat,
      page: () => DirectChatScreen(
        receiverId: Get.arguments?['receiverId'] ?? '',
        receiverName: Get.arguments?['receiverName'] ?? 'User',
        receiverPhotoURL: Get.arguments?['receiverPhotoURL'],
        currentUserId: Supabase.instance.client.auth.currentUser?.id ?? '',
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: groupChat,
      page: () => GroupChatScreen(
        groupId: Get.arguments?['groupId'] ?? '',
        groupName: Get.arguments?['groupName'] ?? 'Group',
        currentUserId: Supabase.instance.client.auth.currentUser?.id ?? '',
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: newChat,
      page: () => NewChatScreen(
        currentUserId: Supabase.instance.client.auth.currentUser?.id ?? '',
      ),
      transition: Transition.rightToLeft,
    ),

    // Note routes
    GetPage(
      name: noteDetail,
      page: () => NoteDetailScreen(
        noteId: Get.arguments?['noteId'] ?? '',
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: createNote,
      page: () => CreateNoteScreen(
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
      ),
      transition: Transition.rightToLeft,
    ),

    // Story routes
    GetPage(
      name: viewStory,
      page: () => ViewStoryScreen(
        storyId: Get.arguments?['storyId'] ?? '',
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: createStory,
      page: () => CreateStoryScreen(
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
      ),
      transition: Transition.rightToLeft,
    ),

    // Settings routes
    GetPage(
      name: editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: friendProfile,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return FriendProfileScreen(
          friendId: args?['friendId'] ?? '',
          currentUserId: args?['currentUserId'] ?? '',
        );
      },
      transition: Transition.rightToLeft,
    ),
  ];
}

// Placeholder screen for routes that need to be implemented

class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Feature coming soon',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
