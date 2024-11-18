package com.sudagoarth.marathon

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.sudagoarth.marathon.handlers.ChannelHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.tasks.Task
import com.google.android.gms.common.api.ApiException
import com.sudagoarth.marathon.services.ActivityService

class MainActivity : FlutterActivity() {

    companion object {
        const val REQUEST_CODE_POST_NOTIFICATIONS = 1001
        const val REQUEST_CODE_GOOGLE_FIT = 1002
    }

    private lateinit var channelHandler: ChannelHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Initialize the ChannelHandler to handle method channel calls
        channelHandler = ChannelHandler(this, flutterEngine)
    }

    override fun onStart() {
        super.onStart()
        requestNotificationPermission()
        requestGoogleFitAuthorization()
    }

    /**
     * Requests notification permission for Android 13 and above
     */
    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    REQUEST_CODE_POST_NOTIFICATIONS
                )
            }
        }
    }

    /**
     * Requests Google Fit authorization for accessing fitness data
     */
    private fun requestGoogleFitAuthorization() {
        val googleSignInOptions = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestScopes(com.google.android.gms.fitness.Fitness.SCOPE_ACTIVITY_READ)
            .build()

        val googleSignInClient = GoogleSignIn.getClient(this, googleSignInOptions)
        googleSignInClient.signInIntent.also { signInIntent ->
            startActivityForResult(signInIntent, REQUEST_CODE_GOOGLE_FIT)
        }
    }

    /**
     * Handles the result of Google Fit authorization and notification permission requests
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_GOOGLE_FIT) {
            handleGoogleFitSignInResult(GoogleSignIn.getSignedInAccountFromIntent(data))
        }
    }

    /**
     * Processes the result from Google Fit sign-in
     */
    private fun handleGoogleFitSignInResult(task: Task<GoogleSignInAccount>) {
        try {
            val account = task.getResult(ApiException::class.java)
            if (account != null) {
                println("Google Fit Authorization Successful")
                // You can start ActivityService here if authorization is successful
                startService(Intent(this, ActivityService::class.java))
            }
        } catch (e: ApiException) {
            e.printStackTrace()
            println("Google Fit Authorization Failed: ${e.statusCode}")
        }
    }

    /**
     * Callback for handling permission results
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            REQUEST_CODE_POST_NOTIFICATIONS -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    println("Notification permission granted")
                } else {
                    println("Notification permission denied")
                }
            }
        }
    }
}
