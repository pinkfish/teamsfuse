package com.teamfuse.flutterfuse;

import android.os.Bundle;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
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
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import java.util.HashMap;
import java.util.Map;
import androidx.annotation.NonNull;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

public class MainActivity extends FlutterActivity /*implements MethodCallHandler */{
    private static final String TAG = "MainActivity";
    public static final String CLICK_ACTION_VALUE = "FLUTTER_NOTIFICATION_CLICK";

    /*
    private MethodChannel channel;
    private Registrar registrar;
    private FirebaseBroadcastReceiver receiver;




    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        Log.i(TAG, "MainActivity");

        channel =
                new MethodChannel(flutterEngine.getDartExecutor(), "plugins.flutter.io/firebase_messaging");
        channel.setMethodCallHandler(this);


        //ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(
        //        flutterEngine
        //);

        //registrar = shimPluginRegistry.registrarFor("com.teamfuse.flutterfuse.MyPretendPlugin");
        //FirebaseApp.initializeApp(registrar.context());
        //receiver = new FirebaseBroadcastReceiver(channel, registrar);
        //registrar.addNewIntentListener(receiver);
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

     */
}
