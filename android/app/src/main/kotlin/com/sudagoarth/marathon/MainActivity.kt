package com.sudagoarth.marathon


import com.sudagoarth.marathon.handlers.ChannelHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private lateinit var channelHandler: ChannelHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channelHandler = ChannelHandler(this, flutterEngine)
    }
}