package com.teamfuse.flutterfuse;

import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import androidx.core.app.NotificationManagerCompat;

/**
 * Created by michaelbui on 24/3/18.
 */

public class ScheduledNotificationReceiver extends BroadcastReceiver {


    @Override
    public void onReceive(final Context context, Intent intent) {
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        Notification notification = intent.getParcelableExtra(FlutterFirebaseMessagingService.NOTIFICATION);
        int notificationId = intent.getIntExtra(FlutterFirebaseMessagingService.NOTIFICATION_ID, 0);
        notificationManager.notify(notificationId, notification);
    }

}
