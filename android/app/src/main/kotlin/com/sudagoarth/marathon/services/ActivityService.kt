package com.sudagoarth.marathon.services

import com.sudagoarth.marathon.R
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class ActivityService : Service() {

    private val CHANNEL_ID = "MarathonChannel"
    private val NOTIFICATION_ID = 1

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification("Starting marathon..."))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> startLiveActivity()
            "UPDATE" -> updateLiveActivity()
            "STOP" -> stopLiveActivity()
        }
        return START_STICKY
    }

    private fun startLiveActivity() {
        updateNotification("Started marathon for John Doe", 5.0, "12:45 PM")
    }

    private fun updateLiveActivity() {
        updateNotification("Runner Update", 21.1, "1:15 PM")
    }

    private fun stopLiveActivity() {
        updateNotification("Stopped marathon for John Doe", 42.2, "Finished")
        stopSelf()
    }

    private fun createNotification(title: String): Notification {
        val customView = RemoteViews(packageName, R.layout.custom_notification_layout)
        customView.setTextViewText(R.id.runner_name, "Runner: John Doe")
        customView.setTextViewText(R.id.runner_position, "Position: 0.0 km")
        customView.setTextViewText(R.id.runner_finish_time, "Estimated Finish: --")

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setCustomContentView(customView)  // For collapsed view
            .setCustomBigContentView(customView)  // For expanded view
            .setPriority(NotificationCompat.PRIORITY_HIGH)  // Ensures visibility
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)  // Shows on lock screen
            .build()
    }

    private fun updateNotification(title: String, position: Double, finishTime: String) {
        val customView = RemoteViews(packageName, R.layout.custom_notification_layout)
        customView.setTextViewText(R.id.runner_name, "Runner: John Doe")
        customView.setTextViewText(R.id.runner_position, "Position: $position km")
        customView.setTextViewText(R.id.runner_finish_time, "Estimated Finish: $finishTime")

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setCustomContentView(customView)
            .setCustomBigContentView(customView)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Marathon Channel",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}