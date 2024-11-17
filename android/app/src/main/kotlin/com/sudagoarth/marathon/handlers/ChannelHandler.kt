package com.sudagoarth.marathon.handlers

import android.content.Context
import android.content.Intent
import com.sudagoarth.marathon.services.ActivityService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.jvm.java

class ChannelHandler(private val context: Context, flutterEngine: FlutterEngine) {

    private val CHANNEL = "com.sudagoarth.marathon/widgetKit"
    private val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

    init {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startLiveActivity" -> {
                    startLiveActivity()
                    result.success("Started Live Activity")
                }
                "updateLiveActivity" -> {
                    updateLiveActivity()
                    result.success("Updated Live Activity")
                }
                "stopLiveActivity" -> {
                    stopLiveActivity()
                    result.success("Stopped Live Activity")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startLiveActivity() {
        val intent = Intent(context, ActivityService::class.java)
        intent.action = "START"
        context.startService(intent)
    }

    private fun updateLiveActivity() {
        val intent = Intent(context, ActivityService::class.java)
        intent.action = "UPDATE"
        context.startService(intent)
    }

    private fun stopLiveActivity() {
        val intent = Intent(context, ActivityService::class.java)
        intent.action = "STOP"
        context.startService(intent)
    }
}
