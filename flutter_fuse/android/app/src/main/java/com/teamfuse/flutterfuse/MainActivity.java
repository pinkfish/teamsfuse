package com.teamfuse.flutterfuse;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
import android.os.Bundle;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;
import com.google.firebase.iid.FirebaseInstanceId;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity implements MethodCallHandler {
    private MethodChannel channel;
    private Registrar registrar;
    private FirebaseBroadcastReceiver receiver;

    private static final String TAG = "MainActivity";
    public static final String CLICK_ACTION_VALUE = "FLUTTER_NOTIFICATION_CLICK";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        Log.i(TAG, "MainActivity");

        channel =
                new MethodChannel(getFlutterView(), "plugins.flutter.io/firebase_messaging");
        channel.setMethodCallHandler(this);
        registrar = registrarFor("com.teamfuse.flutterfuse.MyPretendPlugin");
        FirebaseApp.initializeApp(registrar.context());
        receiver = new FirebaseBroadcastReceiver(channel, registrar);
        registrar.addNewIntentListener(receiver);
    }


     @Override
    public void onMethodCall(MethodCall call, Result result) {
        if ("configure".equals(call.method)) {
            FlutterFirebaseMessagingService.broadcastToken(registrar.context(),  FirebaseInstanceId.getInstance().getToken());
            receiver.sendMessageFromIntent("onLaunch", this.getIntent());
            result.success(null);
        } else if ("subscribeToTopic".equals(call.method)) {
            String topic = call.arguments();
            FirebaseMessaging.getInstance().subscribeToTopic(topic);
            result.success(null);
        } else if ("unsubscribeFromTopic".equals(call.method)) {
            String topic = call.arguments();
            FirebaseMessaging.getInstance().unsubscribeFromTopic(topic);
            result.success(null);
        } else {
            result.notImplemented();
        }
    }
}
