package com.sudagoarth.marathon

import android.content.Context
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.data.DataType
import com.google.android.gms.fitness.data.Field
import com.google.android.gms.fitness.request.DataReadRequest
import java.util.Calendar
import java.util.concurrent.TimeUnit

class GoogleFitManager(private val context: Context) {

    /// Fetches today’s step count from Google Fit.
    fun fetchTodaySteps(completion: (Int?) -> Unit) {
        val googleAccount = GoogleSignIn.getLastSignedInAccount(context)
        if (googleAccount == null) {
            completion(null) // If not signed in, return null
            return
        }

        val end = Calendar.getInstance().timeInMillis
        val start = Calendar.getInstance().apply { set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0) }.timeInMillis

        val readRequest = DataReadRequest.Builder()
            .aggregate(DataType.TYPE_STEP_COUNT_DELTA)
            .setTimeRange(start, end, TimeUnit.MILLISECONDS)
            .bucketByTime(1, TimeUnit.DAYS)
            .build()

        Fitness.getHistoryClient(context, googleAccount)
            .readData(readRequest)
            .addOnSuccessListener { response ->
                val steps = response.buckets.firstOrNull()
                    ?.getDataSet(DataType.AGGREGATE_STEP_COUNT_DELTA)
                    ?.dataPoints
                    ?.firstOrNull()
                    ?.getValue(Field.FIELD_STEPS)
                    ?.asInt() ?: 0
                completion(steps)
            }
            .addOnFailureListener { e ->
                e.printStackTrace()
                completion(null)
            }
    }
}
