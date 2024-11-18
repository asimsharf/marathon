package com.sudagoarth.marathon.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.sudagoarth.marathon.GoogleFitManager
import com.sudagoarth.marathon.R
import java.util.concurrent.TimeUnit
import kotlin.math.roundToInt

class ActivityService : Service() {

    private lateinit var googleFitManager: GoogleFitManager
    private val handler = Handler()
    private val updateInterval = TimeUnit.MINUTES.toMillis(10) // Update every 10 minutes
    private val CHANNEL_ID = "MarathonChannel"
    private val NOTIFICATION_ID = 1

    override fun onCreate() {
        super.onCreate()
        googleFitManager = GoogleFitManager(this)

        // Create the notification channel
        createNotificationChannel()

        // Start the service in the foreground with an initial notification
        startForeground(NOTIFICATION_ID, createNotification("Initializing marathon tracking...", 0.0, "0"))

        // Start periodic updates
        startPeriodicStepUpdates()
    }

    /// Starts periodic updates to fetch and update step count data every 10 minutes.
    private fun startPeriodicStepUpdates() {
        handler.post(object : Runnable {
            override fun run() {
                // Fetch step count from Google Fit
                googleFitManager.fetchTodaySteps { steps ->
                    if (steps != null) {
                        updateLiveActivity(steps)
                    }
                }
                handler.postDelayed(this, updateInterval)
            }
        })
    }

    /// Updates the notification with the latest step count and distance.
    private fun updateLiveActivity(steps: Int) {
        val distanceKm = (steps / 1300.0).roundToInt() / 1000.0 // Estimate distance based on steps
        updateNotification("Marathon in progress...", distanceKm, steps.toString())
    }

    /// Creates a notification for the foreground service.
    private fun createNotification(title: String, distanceKm: Double, steps: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText("Distance: $distanceKm km | Steps: $steps")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    /// Updates the live notification with the latest data.
    private fun updateNotification(title: String, distanceKm: Double, steps: String) {
        val notification = createNotification(title, distanceKm, steps)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    /// Creates a notification channel required for Android 8.0+.
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Marathon Tracking Channel",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null) // Stop periodic updates
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
