// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.teamfuse.flutterfuse;

import android.app.*;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.text.Html;
import android.text.Spanned;
import android.util.Log;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import io.flutter.app.FlutterActivity;
import io.flutter.app.FlutterApplication;
import io.flutter.view.FlutterNativeView;

import java.lang.reflect.Type;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class FlutterFirebaseMessagingService extends FirebaseMessagingService {

  public static final String ACTION_REMOTE_MESSAGE =
      "io.flutter.plugins.firebasemessaging.NOTIFICATION";
  public static final String EXTRA_REMOTE_MESSAGE = "notification";
  public static final String NOTIFICATION = "notification";
  public static final String NOTIFICATION_ID = "notification_id";
  private static final String SELECT_NOTIFICATION = "SELECT_NOTIFICATION";
  private static final String TAG = "FlutterFirebaseMess";
  private static final String TIMESTAMP = "ts";
  private static final String BODY = "body";
  private static final String TITLE = "title";
  private static final String KEY = "k";
  private static final String ADDR = "a";
  private static final String PLACE_ID = "p";
  private static final String PAYLOAD = "payload";
  private static final String NOTIFICATION_SHARED_PREF = "lib_notification_data";

  Random rand = new Random();

  public FlutterFirebaseMessagingService() {}

  /**
   * Called when message is received.
   *
   * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
   */
  @Override
  public void onMessageReceived(RemoteMessage remoteMessage) {
    Log.i(TAG, "Got a message, yay!");

    // Now we do things with the notifications to schedule them.  This makes sure we
    // always have location notifications to mess with.
    if (remoteMessage.getData().containsKey(BODY)
        && remoteMessage.getData().containsKey(TIMESTAMP)) {
      Long ts = Long.parseLong(remoteMessage.getData().get(TIMESTAMP));
      String body = remoteMessage.getData().get(BODY);
      String title = remoteMessage.getData().get(TITLE);
      String key = remoteMessage.getData().get(KEY);
      String addr = remoteMessage.getData().get(ADDR);
      String placeId = remoteMessage.getData().get(PLACE_ID);

      // Schedule the notification.
      Map<String, Integer> notificationMapping = loadNotificationMapping(this);
      // Yay!  Otherwise we need to find a new id.
      int notificationMappingId;
      if (!notificationMapping.containsKey(key)) {
        int id;
        do {
          id = rand.nextInt();
        } while (notificationMapping.containsValue(id));
        notificationMapping.put(key, id);
        // Write out on a change.
        saveNotificationMapping(this, notificationMapping);
        notificationMappingId = id;
      } else {
        notificationMappingId = notificationMapping.get(key);
      }
      Intent intent = new Intent(getApplicationContext(), MainActivity.class);
      intent.setAction(SELECT_NOTIFICATION);
      intent.putExtra(PAYLOAD, key);
      PendingIntent pendingIntent =
          PendingIntent.getActivity(
              getApplicationContext(),
              notificationMappingId,
              intent,
              PendingIntent.FLAG_UPDATE_CURRENT);
      NotificationCompat.Builder builder =
          new NotificationCompat.Builder(getApplicationContext(), "GAME")
              .setSmallIcon(R.drawable.ic_launcher)
              .setContentTitle(fromHtml(title))
              .setContentText(fromHtml(body))
              .setAutoCancel(false)
              .setContentIntent(pendingIntent);
      builder.addAction(R.drawable.ic_launcher, "DETAILS", pendingIntent);
      Intent urlIntent = new Intent(Intent.ACTION_VIEW);
      urlIntent.setData(
          Uri.parse(
              "https://www.google.com/maps/dir/?api=1&destination="
                  + addr
                  + "&destination_place_id="
                  + placeId));
      PendingIntent directionsIntent =
          PendingIntent.getActivity(
              getApplicationContext(),
              notificationMappingId + 1000,
              urlIntent,
              PendingIntent.FLAG_UPDATE_CURRENT);
      builder.addAction(R.drawable.ic_launcher, "DIRECTIONS", directionsIntent);

      // .setOngoing(BooleanUtils.getValue(notificationDetails.ongoing));
      Notification notification = builder.build();
      NotificationManagerCompat notificationManagerCompat = getNotificationManager();
      notificationManagerCompat.notify(notificationMappingId, notification);

      // Show the notification 2 hours ahead.
      long cutOffTime = Calendar.getInstance().getTimeInMillis() - 2 * 60 * 60000;
      if (ts > cutOffTime) {
        // Show it right now.
        NotificationManagerCompat notificationManager =
            NotificationManagerCompat.from(getApplicationContext());

        notificationManager.notify(notificationMappingId, notification);
      } else {
        Intent notificationIntent =
            new Intent(getApplicationContext(), ScheduledNotificationReceiver.class);
        notificationIntent.putExtra(NOTIFICATION_ID, notificationMappingId);
        notificationIntent.putExtra(NOTIFICATION, notification);
        PendingIntent pendingIntentAlarm =
            PendingIntent.getBroadcast(
                getApplicationContext(),
                notificationMappingId,
                notificationIntent,
                PendingIntent.FLAG_CANCEL_CURRENT);
        builder.setContentIntent(pendingIntentAlarm);

        // Do this in the future.
        AlarmManager alarmManager = getAlarmManager(getApplicationContext());
        alarmManager.set(AlarmManager.RTC_WAKEUP, cutOffTime, pendingIntent);
      }
    }

    // Send to the main app last so we don't get issues with overwriting the
    // shared pref.
    FlutterNativeView view = viewFromAppContext(getApplicationContext());

    // Send to the main flutter app if it is running.
    if (view != null) {
      Intent intent = new Intent(ACTION_REMOTE_MESSAGE);
      intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
      LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }
  }

  // This returns the FlutterView for the main FlutterActivity if there is one.
  private static FlutterNativeView viewFromAppContext(Context context) {
    Application app = (Application) context;
    if (!(app instanceof FlutterApplication)) {
      Log.i(TAG, "viewFromAppContext app not a FlutterApplication");
      return null;
    }
    FlutterApplication flutterApp = (FlutterApplication) app;
    Activity activity = flutterApp.getCurrentActivity();
    if (activity == null) {
      Log.i(TAG, "viewFromAppContext activity is null");
      return null;
    }
    if (!(activity instanceof FlutterActivity)) {
      Log.i(TAG, "viewFromAppContext activity is not a FlutterActivity");
      return null;
    }
    FlutterActivity flutterActivity = (FlutterActivity) activity;
    return flutterActivity.getFlutterView().getFlutterNativeView();
  }

  private static Spanned fromHtml(String html) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      return Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY);
    } else {
      return Html.fromHtml(html);
    }
  }

  private static AlarmManager getAlarmManager(Context context) {
    AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
    return alarmManager;
  }

  private NotificationManagerCompat getNotificationManager() {
    return NotificationManagerCompat.from(getApplicationContext());
  }

  private static Map<String, Integer> loadNotificationMapping(Context context) {
    Map<String, Integer> notificationMapping = new HashMap<String, Integer>();
    SharedPreferences sharedPreferences =
        context.getSharedPreferences(NOTIFICATION_SHARED_PREF, Context.MODE_PRIVATE);
    String json = sharedPreferences.getString(NOTIFICATION_SHARED_PREF, null);
    if (json != null) {
      Gson gson = getGsonBuilder();
      Type type = new TypeToken<Map<String, Integer>>() {}.getType();
      notificationMapping = gson.fromJson(json, type);
    }
    return notificationMapping;
  }

  @NonNull
  private static Gson getGsonBuilder() {
    GsonBuilder builder = new GsonBuilder();
    return builder.create();
  }

  private static void saveNotificationMapping(
      Context context, Map<String, Integer> notificationMapping) {
    Gson gson = getGsonBuilder();
    String json = gson.toJson(notificationMapping);
    SharedPreferences sharedPreferences =
        context.getSharedPreferences(NOTIFICATION_SHARED_PREF, Context.MODE_PRIVATE);
    SharedPreferences.Editor editor = sharedPreferences.edit();
    editor.putString(NOTIFICATION_SHARED_PREF, json);
    editor.commit();
  }
}
