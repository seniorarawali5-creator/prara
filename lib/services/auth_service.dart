import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prashant/models/user_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();
final supabase = Supabase.instance.client;

abstract class AuthService {
  Future<AppUser?> login(String email, String password);
  Future<AppUser?> signup(
    String email,
    String password,
    String fullName,
    String mobileNumber,
  );
  Future<void> sendOTP(String email);
  Future<void> verifyOTPAndSignup(String email, String otp);
  Future<AppUser?> signUpWithGoogle();
  Future<AppUser?> loginWithGoogle();
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<AppUser?> getCurrentUser();
  Future<void> updateProfile(AppUser user);
}

class AuthServiceImpl implements AuthService {

  @override
  Future<AppUser?> login(String email, String password) async {
    try {
      logger.i('🔐 Attempting login for: $email');
      
      final authResult = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResult.user != null) {
        logger.i('✅ Auth login successful');
        
        try {
          final userDoc = await supabase
              .from('users')
              .select()
              .eq('id', authResult.user!.id)
              .single();

          logger.i('✅ Login successful for: $email');
          return AppUser.fromJson({
            ...userDoc,
            'id': authResult.user!.id,
          });
        } catch (e) {
          logger.w('⚠️ Could not fetch user profile, creating one: $e');
          
          // Create user profile if it doesn't exist
          try {
            final user = AppUser(
              id: authResult.user!.id,
              email: authResult.user!.email ?? email,
              fullName: authResult.user!.userMetadata?['full_name'] ?? 'User',
              mobileNumber: authResult.user!.userMetadata?['mobile_number'] ?? '',
              role: 'user',
              createdAt: DateTime.now(),
              isDarkMode: false,
            );
            
            final userJson = user.toJson();
            userJson.removeWhere((k, v) => k == 'createdAt');
            
            await supabase.from('users').insert(userJson);
            logger.i('✅ Created missing user profile');
            return user;
          } catch (createError) {
            logger.e('❌ Error creating user profile: $createError');
            rethrow;
          }
        }
      }
      return null;
    } on AuthException catch (e) {
      logger.e('❌ Login error: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<AppUser?> signup(
    String email,
    String password,
    String fullName,
    String mobileNumber,
  ) async {
    try {
      logger.i('📝 Attempting signup for: $email');
      
      // Simple signup without email verification
      final authResult = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'mobile_number': mobileNumber,
        },
      );

      if (authResult.user != null) {
        logger.i('✅ Auth user created: ${authResult.user!.id}');
        
        // Create user profile in database
        final user = AppUser(
          id: authResult.user!.id,
          email: email,
          fullName: fullName,
          mobileNumber: mobileNumber,
          role: 'user',
          createdAt: DateTime.now(),
          isDarkMode: false,
        );

        // Insert user into users table
        final userJson = user.toJson();
        userJson.removeWhere((k, v) => k == 'createdAt');
        
        await supabase
            .from('users')
            .insert(userJson);
        
        logger.i('✅ User profile created in database');
        logger.i('✅ Signup successful for: $email');
        return user;
      }
      return null;
    } on AuthException catch (e) {
      logger.e('❌ Signup error: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('❌ Signup exception: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendOTP(String email) async {
    try {
      logger.i('📧 Sending OTP to: $email');
      await supabase.auth.signInWithOtp(email: email);
      logger.i('✅ OTP sent to $email');
    } on AuthException catch (e) {
      logger.e('❌ Send OTP error: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('❌ Send OTP exception: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyOTPAndSignup(String email, String otp) async {
    try {
      logger.i('✔️ Verifying OTP for: $email');
      
      final authResult = await supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (authResult.user != null) {
        logger.i('✅ OTP verified successfully');
        
        // Create user profile in database
        try {
          final userDoc = await supabase
              .from('users')
              .select()
              .eq('id', authResult.user!.id)
              .maybeSingle();

          if (userDoc == null) {
            // Profile doesn't exist, create it
            final user = AppUser(
              id: authResult.user!.id,
              email: email,
              fullName: email.split('@')[0], // Use email username as default name
              mobileNumber: '',
              role: 'user',
              createdAt: DateTime.now(),
              isDarkMode: false,
            );

            final userJson = user.toJson();
            userJson.removeWhere((k, v) => k == 'createdAt');
            
            await supabase.from('users').insert(userJson);
            logger.i('✅ User profile created');
          }
        } catch (e) {
          logger.w('Profile creation: $e');
        }
        
        logger.i('✅ Signup with OTP successful');
      }
    } on AuthException catch (e) {
      logger.e('❌ OTP verification error: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('❌ OTP verification exception: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      logger.i('👋 Logging out...');
      await supabase.auth.signOut();
      logger.i('✅ Logout successful');
    } catch (e) {
      logger.e('❌ Logout error: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser?> signUpWithGoogle() async {
    try {
      logger.i('🔐 Attempting Google signup');
      
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.prashant.app://callback',
      );
      
      // Get the authenticated user from currentUser after OAuth
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        logger.i('✅ Google auth successful');
        
        // Create or get user profile
        final email = currentUser.email ?? '';
        final fullName = currentUser.userMetadata?['full_name'] ?? 'Google User';
        
        try {
          // Try to fetch existing profile
          final userDoc = await supabase
              .from('users')
              .select()
              .eq('id', currentUser.id)
              .single();
          
          return AppUser.fromJson({
            ...userDoc,
            'id': currentUser.id,
          });
        } catch (e) {
          // Create new profile if doesn't exist
          logger.i('Creating new profile for Google user');
          final user = AppUser(
            id: currentUser.id,
            email: email,
            fullName: fullName,
            mobileNumber: '',
            role: 'user',
            createdAt: DateTime.now(),
            isDarkMode: false,
          );
          
          final userJson = user.toJson();
          userJson.removeWhere((k, v) => k == 'createdAt');
          
          try {
            await supabase.from('users').insert(userJson);
          } catch (insertError) {
            logger.w('Profile already exists or insert failed: $insertError');
          }
          
          return user;
        }
      }
      return null;
    } catch (e) {
      logger.e('❌ Google signup error: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser?> loginWithGoogle() async {
    try {
      logger.i('🔐 Attempting Google login');
      
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.prashant.app://callback',
      );
      
      // Get the authenticated user from currentUser after OAuth
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        logger.i('✅ Google login successful');
        
        try {
          final userDoc = await supabase
              .from('users')
              .select()
              .eq('id', currentUser.id)
              .single();

          return AppUser.fromJson({
            ...userDoc,
            'id': currentUser.id,
          });
        } catch (e) {
          logger.w('User profile not found, creating one');
          
          // Create profile if missing
          final email = currentUser.email ?? '';
          final fullName = currentUser.userMetadata?['full_name'] ?? 'Google User';
          
          final user = AppUser(
            id: currentUser.id,
            email: email,
            fullName: fullName,
            mobileNumber: '',
            role: 'user',
            createdAt: DateTime.now(),
            isDarkMode: false,
          );
          
          final userJson = user.toJson();
          userJson.removeWhere((k, v) => k == 'createdAt');
          
          try {
            await supabase.from('users').insert(userJson);
          } catch (insertError) {
            logger.w('Profile creation error: $insertError');
          }
          
          return user;
        }
      }
      return null;
    } catch (e) {
      logger.e('❌ Google login error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      logger.i('🔄 Resetting password for: $email');
      await supabase.auth.resetPasswordForEmail(email);
      logger.i('✅ Password reset email sent');
    } on AuthException catch (e) {
      logger.e('❌ Password reset error: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final supabaseUser = supabase.auth.currentUser;
      
      if (supabaseUser != null) {
        final userDoc = await supabase
            .from('users')
            .select()
            .eq('id', supabaseUser.id)
            .single();

        return AppUser.fromJson({
          ...userDoc,
          'id': supabaseUser.id,
        });
      }
      return null;
    } catch (e) {
      logger.e('❌ Get current user error: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile(AppUser user) async {
    try {
      logger.i('✏️ Updating profile for: ${user.email}');
      await supabase.from('users').update(user.toJson()).eq('id', user.id);
      logger.i('✅ Profile updated successfully');
    } catch (e) {
      logger.e('❌ Update profile error: $e');
      rethrow;
    }
  }

  // Additional helper methods
  bool isUserLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  Stream<AuthState> authStateChanges() {
    return supabase.auth.onAuthStateChange;
  }
}

