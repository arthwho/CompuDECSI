const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Function to send push notifications
exports.sendPushNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    if (notification.status !== 'pending') {
      return null;
    }

    try {
      const message = {
        token: notification.fcmToken,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        android: {
          priority: 'high',
          notification: {
            channelId: 'event_notifications',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      
      // Update notification status
      await snap.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
      });

      console.log('Successfully sent message:', response);
      return response;
    } catch (error) {
      console.error('Error sending message:', error);
      
      // Update notification status to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      throw error;
    }
  });

// Cloud Function to send event reminders (can be triggered by a scheduled function)
exports.sendEventReminders = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const thirtyMinutesFromNow = new Date(now.toDate().getTime() + 30 * 60 * 1000);
    
    try {
      // Get events that start in 30 minutes
      const eventsSnapshot = await admin.firestore()
        .collection('events')
        .where('dateTime', '>=', now.toDate())
        .where('dateTime', '<=', thirtyMinutesFromNow)
        .get();

      for (const eventDoc of eventsSnapshot.docs) {
        const event = eventDoc.data();
        
              // Get all enrolled users for this event
      const enrollmentsSnapshot = await admin.firestore()
        .collection('events')
        .doc(eventDoc.id)
        .collection('enrollments')
        .get();

        for (const enrollmentDoc of enrollmentsSnapshot.docs) {
          const enrollment = enrollmentDoc.data();
          const userId = enrollmentDoc.id; // The document ID is the userId
          
          // Get user's FCM token
          const userDoc = await admin.firestore()
            .collection('users')
            .doc(userId)
            .get();

          if (userDoc.exists && userDoc.data().fcmToken) {
            const message = {
              token: userDoc.data().fcmToken,
              notification: {
                title: 'Lembrete: ' + event.name,
                body: `Seu evento começa em 30 minutos!\nLocal: ${event.local}`,
              },
              data: {
                eventId: eventDoc.id,
                type: 'event_reminder',
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'event_reminders',
                  priority: 'high',
                  defaultSound: true,
                  defaultVibrateTimings: true,
                },
              },
              apns: {
                payload: {
                  aps: {
                    sound: 'default',
                    badge: 1,
                  },
                },
              },
            };

            try {
              await admin.messaging().send(message);
                        console.log(`Sent reminder to user ${userId} for event ${event.name}`);
        } catch (error) {
          console.error(`Failed to send reminder to user ${userId}:`, error);
            }
          }
        }
      }
    } catch (error) {
      console.error('Error sending event reminders:', error);
    }
  });

// Migration function to move feedback to new structure
exports.migrateFeedback = functions.https.onRequest(async (req, res) => {
  try {
    console.log('Starting feedback migration...');
    
    // Get all old feedback
    const oldFeedbackSnapshot = await admin.firestore()
      .collection('feedback')
      .get();
    
    console.log(`Found ${oldFeedbackSnapshot.size} feedback entries to migrate`);
    
    if (oldFeedbackSnapshot.empty) {
      return res.json({ 
        success: true, 
        message: 'No feedback found to migrate',
        migrated: 0 
      });
    }
    
    const batch = admin.firestore().batch();
    let migratedCount = 0;
    let errorCount = 0;
    
    for (const doc of oldFeedbackSnapshot.docs) {
      try {
        const feedbackData = doc.data();
        const eventId = feedbackData.eventId;
        
        if (!eventId) {
          console.log(`Skipping feedback ${doc.id} - no eventId`);
          errorCount++;
          continue;
        }
        
        // Check if the event exists
        const eventDoc = await admin.firestore()
          .collection('events')
          .doc(eventId)
          .get();
        
        if (!eventDoc.exists) {
          console.log(`Skipping feedback ${doc.id} - event ${eventId} does not exist`);
          errorCount++;
          continue;
        }
        
        // Create new feedback document in events/{eventId}/feedback/{feedbackId}
        const newFeedbackRef = admin.firestore()
          .collection('events')
          .doc(eventId)
          .collection('feedback')
          .doc(doc.id);
        
        // Prepare feedback data for new structure
        const newFeedbackData = {
          ...feedbackData,
          migratedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        
        batch.set(newFeedbackRef, newFeedbackData);
        migratedCount++;
        
        console.log(`Migrated feedback ${doc.id} to events/${eventId}/feedback/${doc.id}`);
        
      } catch (error) {
        console.error(`Error migrating feedback ${doc.id}:`, error);
        errorCount++;
      }
    }
    
    // Commit the batch
    await batch.commit();
    
    console.log(`Migration completed: ${migratedCount} migrated, ${errorCount} errors`);
    
    return res.json({
      success: true,
      message: 'Feedback migration completed',
      migrated: migratedCount,
      errors: errorCount
    });
    
  } catch (error) {
    console.error('Error during feedback migration:', error);
    return res.status(500).json({
      success: false,
      error: error.message
    });
  }
});


