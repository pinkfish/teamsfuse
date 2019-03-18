package com.teamfuse.flutterfuse;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import com.google.firebase.messaging.RemoteMessage;

import java.util.HashMap;
import java.util.Map;


/**
 * Created by ddb on 5/22/18.
 */

public class FirebaseBroadcastReceiver extends BroadcastReceiver implements NewIntentListener {
    final private MethodChannel channel;
    final private Registrar registrar;

    private static final String TAG = "FirebaseBroadcastRec";


    public FirebaseBroadcastReceiver(MethodChannel channel, Registrar registrar) {
        this.channel = channel;
        this.registrar = registrar;

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(FlutterFirebaseInstanceIDService.ACTION_TOKEN);
        intentFilter.addAction(FlutterFirebaseMessagingService.ACTION_REMOTE_MESSAGE);
        LocalBroadcastManager manager = LocalBroadcastManager.getInstance(registrar.context());
        manager.registerReceiver(this, intentFilter);
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        return sendMessageFromIntent("onResume", intent);
    }

    // BroadcastReceiver implementation.
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Log.i(TAG, "onReceive " + action);
        if (action.equals(FlutterFirebaseInstanceIDService.ACTION_TOKEN)) {
            String token = intent.getStringExtra(FlutterFirebaseInstanceIDService.EXTRA_TOKEN);
            channel.invokeMethod("onToken", token);
        } else if (action.equals(FlutterFirebaseMessagingService.ACTION_REMOTE_MESSAGE)) {
            RemoteMessage message =
                    intent.getParcelableExtra(FlutterFirebaseMessagingService.EXTRA_REMOTE_MESSAGE);
            channel.invokeMethod("onMessage", message.getData());
        }
    }


    /** @return true if intent contained a message to send. */
    public boolean sendMessageFromIntent(String method, Intent intent) {
        if (MainActivity.CLICK_ACTION_VALUE.equals(intent.getAction())
                || MainActivity.CLICK_ACTION_VALUE.equals(intent.getStringExtra("click_action"))) {
            Map<String, String> message = new HashMap<>();
            Bundle extras = intent.getExtras();
            for (String key : extras.keySet()) {
                message.put(key, extras.get(key).toString());
            }
            channel.invokeMethod(method, message);
            return true;
        }
        return false;
    }
}
