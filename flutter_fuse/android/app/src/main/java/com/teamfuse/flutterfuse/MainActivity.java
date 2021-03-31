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

}
