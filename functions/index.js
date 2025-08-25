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
          .collection('enrollments')
          .where('eventId', '==', eventDoc.id)
          .get();

        for (const enrollmentDoc of enrollmentsSnapshot.docs) {
          const enrollment = enrollmentDoc.data();
          
          // Get user's FCM token
          const userDoc = await admin.firestore()
            .collection('users')
            .doc(enrollment.userId)
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
              console.log(`Sent reminder to user ${enrollment.userId} for event ${event.name}`);
            } catch (error) {
              console.error(`Failed to send reminder to user ${enrollment.userId}:`, error);
            }
          }
        }
      }
    } catch (error) {
      console.error('Error sending event reminders:', error);
    }
  });
