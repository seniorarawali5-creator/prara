/**
 * Firebase Cloud Functions for Prashant App
 * Deploy these using: firebase deploy --only functions
 * 
 * Prerequisites:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Initialize functions: firebase init functions
 * 3. Replace /functions/src/index.ts with this file
 * 4. Run: npm install
 * 5. Deploy: firebase deploy --only functions
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ============= USER FUNCTIONS =============

/**
 * Create default user data when new user signs up
 * Trigger: On Firebase Auth user creation
 */
export const createUserProfile = functions.auth.user().onCreate(async (user) => {
  const userData = {
    id: user.uid,
    email: user.email,
    displayName: user.displayName || 'Anonymous User',
    photoURL: user.photoURL || '',
    role: 'user',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    isActive: true,
    lastLogin: admin.firestore.FieldValue.serverTimestamp(),
    stats: {
      totalStudyHours: 0,
      totalScreenTime: 0,
      postcount: 0,
      friendCount: 0,
    },
  };

  try {
    await db.collection('users').doc(user.uid).set(userData);
    console.log(`User profile created for: ${user.uid}`);
  } catch (error) {
    console.error(`Error creating user profile: ${error}`);
  }
});

/**
 * Clean up user data when user is deleted
 * Trigger: On Firebase Auth user deletion
 */
export const deleteUserProfile = functions.auth.user().onDelete(async (user) => {
  try {
    // Delete user document
    await db.collection('users').doc(user.uid).delete();

    // Delete user's chats (only as creator)
    const chatsSnapshot = await db
      .collectionGroup('chats')
      .where('createdBy', '==', user.uid)
      .get();

    const batch = db.batch();
    chatsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    await batch.commit();

    console.log(`User data deleted for: ${user.uid}`);
  } catch (error) {
    console.error(`Error deleting user profile: ${error}`);
  }
});

// ============= FRIEND REQUEST FUNCTIONS =============

/**
 * Handle friend request acceptance
 * Trigger: When friend request status is updated to 'accepted'
 */
export const onFriendRequestAccepted = functions.firestore
  .document('friend_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Only process if status changed to accepted
    if (beforeData.status !== 'accepted' && afterData.status === 'accepted') {
      const { senderId, receiverId } = afterData;

      try {
        const batch = db.batch();

        // Create friendship document
        const friendshipId = [senderId, receiverId].sort().join('_');
        batch.set(db.collection('friendships').doc(friendshipId), {
          userIds: [senderId, receiverId],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update user stats
        batch.update(db.collection('users').doc(senderId), {
          'stats.friendCount': admin.firestore.FieldValue.increment(1),
        });
        batch.update(db.collection('users').doc(receiverId), {
          'stats.friendCount': admin.firestore.FieldValue.increment(1),
        });

        await batch.commit();

        // Send notifications
        await sendFriendRequestNotification(
          senderId,
          receiverId,
          `${afterData.receiverName} accepted your friend request!`
        );

        console.log(`Friend request accepted between ${senderId} and ${receiverId}`);
      } catch (error) {
        console.error(`Error accepting friend request: ${error}`);
      }
    }
  });

/**
 * Send push notification
 */
async function sendFriendRequestNotification(
  toUserId: string,
  fromUserId: string,
  message: string
) {
  try {
    const userDoc = await db.collection('users').doc(toUserId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (fcmToken) {
      await messaging.send({
        notification: {
          title: 'Friend Request',
          body: message,
        },
        data: {
          userId: fromUserId,
          type: 'friend_request',
        },
        token: fcmToken,
      });
    }
  } catch (error) {
    console.error(`Error sending notification: ${error}`);
  }
}

// ============= MESSAGE FUNCTIONS =============

/**
 * Update last message time when message is sent
 * Trigger: When message is created
 */
export const updateChatMetadata = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const { chatId } = context.params;

    try {
      await db.collection('chats').doc(chatId).update({
        lastMessage: messageData.text,
        lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
        lastSenderId: messageData.senderId,
      });
    } catch (error) {
      console.error(`Error updating chat metadata: ${error}`);
    }
  });

// ============= STORY FUNCTIONS =============

/**
 * Delete expired stories (older than 24 hours)
 * Trigger: Scheduled function (run every hour)
 */
export const deleteExpiredStories = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    try {
      const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

      const snapshot = await db
        .collectionGroup('stories')
        .where('createdAt', '<', admin.firestore.Timestamp.fromDate(oneDayAgo))
        .get();

      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`Deleted ${snapshot.docs.length} expired stories`);
    } catch (error) {
      console.error(`Error deleting expired stories: ${error}`);
    }
  });

// ============= ANALYTICS FUNCTIONS =============

/**
 * Calculate user statistics
 * Trigger: Scheduled function (run daily)
 */
export const aggregateDailyStats = functions.pubsub
  .schedule('every day 00:00')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    try {
      const usersSnapshot = await db.collection('users').get();

      const batch = db.batch();

      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Get today's study sessions
        const sessionsSnapshot = await db
          .collection('users')
          .doc(userId)
          .collection('study_sessions')
          .where('startTime', '>=', admin.firestore.Timestamp.fromDate(today))
          .get();

        let totalStudyMinutes = 0;
        sessionsSnapshot.docs.forEach((doc) => {
          totalStudyMinutes += doc.data().duration || 0;
        });

        // Store daily statistic
        const statsDate = today.toISOString().split('T')[0];
        batch.set(
          db
            .collection('users')
            .doc(userId)
            .collection('daily_stats')
            .doc(statsDate),
          {
            date: admin.firestore.Timestamp.fromDate(today),
            studyHours: totalStudyMinutes / 60,
            sessionCount: sessionsSnapshot.docs.length,
          }
        );
      }

      await batch.commit();
      console.log('Daily statistics aggregated successfully');
    } catch (error) {
      console.error(`Error aggregating daily stats: ${error}`);
    }
  });

// ============= NOTIFICATION FUNCTIONS =============

/**
 * Send notification when user gets mentioned in a comment
 * Trigger: When mention is created
 */
export const sendMentionNotification = functions.firestore
  .document('mentions/{mentionId}')
  .onCreate(async (snap, context) => {
    const mentionData = snap.data();
    const { mentionedUserId, mentioningUserName } = mentionData;

    try {
      const mentionedUser = await db
        .collection('users')
        .doc(mentionedUserId)
        .get();
      const fcmToken = mentionedUser.data()?.fcmToken;

      if (fcmToken) {
        await messaging.send({
          notification: {
            title: 'You were mentioned',
            body: `${mentioningUserName} mentioned you`,
          },
          data: {
            type: 'mention',
            userId: mentionData.mentioningUserId,
          },
          token: fcmToken,
        });
      }
    } catch (error) {
      console.error(`Error sending mention notification: ${error}`);
    }
  });

// ============= UTILITY FUNCTIONS =============

/**
 * HTTP function to manually trigger actions
 * Usage: Call from app using Cloud Functions HTTP trigger
 */
export const triggerAnalyticsUpdate = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    try {
      const userId = context.auth.uid;
      // Perform analytics update for the user
      console.log(`Analytics update triggered for user: ${userId}`);

      return { success: true, message: 'Analytics updated' };
    } catch (error) {
      throw new functions.https.HttpsError('internal', String(error));
    }
  }
);

/**
 * Backup database collections
 * Usage: Scheduled function (run weekly)
 */
export const backupDatabase = functions.pubsub
  .schedule('every saturday 02:00')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    try {
      console.log('Database backup started...');
      // Implement your backup logic here
      // You can use Cloud Firestore export/import API
      console.log('Database backup completed');
    } catch (error) {
      console.error(`Error during backup: ${error}`);
    }
  });
