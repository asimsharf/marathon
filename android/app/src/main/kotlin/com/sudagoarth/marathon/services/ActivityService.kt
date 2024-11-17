package com.sudagoarth.marathon.services


import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.sudagoarth.marathon.R
import kotlin.jvm.java

class ActivityService : Service() {

    private val CHANNEL_ID = "MarathonChannel"
    private val NOTIFICATION_ID = 1

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification("Marathon is starting..."))
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
        updateNotification("Started marathon Live Activity for John Doe")
    }

    private fun updateLiveActivity() {
        updateNotification("Updated marathon Live Activity for John Doe - Position: 21.1 km")
    }

    private fun stopLiveActivity() {
        updateNotification("Stopped marathon Live Activity for John Doe")
        stopSelf()
    }

    private fun createNotification(message: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Marathon Activity")
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .build()
    }

    private fun updateNotification(message: String) {
        val notification = createNotification(message)
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Marathon Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}