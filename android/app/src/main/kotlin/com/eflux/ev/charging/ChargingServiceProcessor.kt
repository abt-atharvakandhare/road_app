package com.eflux.ev.charging

import android.app.ForegroundServiceStartNotAllowedException
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges the Flutter live activity dispatcher to the Android [ChargingForegroundService].
 *
 * The Dart side invokes `showLiveActivity` (start/update) and `endLiveActivity` (stop).
 * The ContentValues map mirrors the iOS payload (currency, energy Wh, stateOfCharge %,
 * costCurrentTotal cents, sessionStartedAt ms, activeSessionId, locationName).
 */
class ChargingServiceProcessor(
    private val context: Context,
    flutterEngine: FlutterEngine,
) {
    companion object {
        private const val TAG = "ChargingServiceProcessor"
        private const val CHANNEL_NAME = "io.e-flux.mobile/chargingService"
        private const val METHOD_SHOW = "showLiveActivity"
        private const val METHOD_END = "endLiveActivity"
    }

    init {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SHOW -> {
                    startOrUpdateService(call)
                    result.success(mapOf("status" to "updated"))
                }
                METHOD_END -> {
                    stopService()
                    result.success(mapOf("status" to "ended"))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startOrUpdateService(call: MethodCall) {
        val args = call.arguments as? Map<*, *> ?: return

        val energyWh = (args["energy"] as? Number)?.toDouble() ?: 0.0
        val stateOfCharge = (args["stateOfCharge"] as? Number)?.toInt()
        val costCents = (args["costCurrentTotal"] as? Number)?.toInt() ?: 0
        val currency = (args["currency"] as? String) ?: "EUR"
        val sessionStartedAtMs = (args["sessionStartedAt"] as? Number)?.toLong()
        val locationName = args["locationName"] as? String
        val remainingMinutes = (args["estimatedTimeRemainingMinutes"] as? Number)?.toInt() ?: -1

        // Compact (unlabelled) values used directly in the API 36+ header.
        val durationCompact = sessionStartedAtMs?.let { formatHm(durationMinutes(it)) }
        val kwhCompact = formatKwh(energyWh)
        val costCompact = formatCost(costCents, currency)

        val primaryMetric = stateOfCharge?.let { "$it%" } ?: kwhCompact

        // Labelled stats for the legacy multi-line BigTextStyle body. Each becomes
        // its own line, so the labels carry their weight.
        val kwhStat = "$kwhCompact charged"
        val durationStat = durationCompact?.let { "Duration: $it" }
        val costStat = costCompact?.let { "Session cost: $it" }

        // Right-aligned stats stack. Prefer duration on top, kWh below — matches Figma.
        val statPrimary = durationStat ?: kwhStat
        val statSecondary = when {
            durationStat != null -> kwhStat
            else -> costStat
        }

        // Compact, unlabelled stats for the API 36+ header line — the system slot is
        // tight (mid-word truncation otherwise). Context (charging notification) makes
        // labels redundant.
        val compactStats = listOfNotNull(durationCompact, kwhCompact, costCompact)
            .joinToString(separator = " · ")

        // Sentence-style chip text per the Android 16 promoted-ongoing design.
        // Degrades gracefully when remaining-minutes is unknown.
        val chipText = buildChipText(stateOfCharge, energyWh, remainingMinutes)

        val intent = Intent(context, ChargingForegroundService::class.java).apply {
            action = ChargingForegroundService.ACTION_START_OR_UPDATE
            putExtra(ChargingForegroundService.EXTRA_LOCATION_NAME, locationName)
            putExtra(ChargingForegroundService.EXTRA_PRIMARY_METRIC, primaryMetric)
            putExtra(ChargingForegroundService.EXTRA_STAT_PRIMARY, statPrimary)
            putExtra(ChargingForegroundService.EXTRA_STAT_SECONDARY, statSecondary)
            putExtra(ChargingForegroundService.EXTRA_SUBTITLE, costStat.takeIf { durationStat != null })
            putExtra(ChargingForegroundService.EXTRA_PROGRESS, stateOfCharge ?: -1)
            putExtra(ChargingForegroundService.EXTRA_COLLAPSED_TITLE, "Charging: $primaryMetric")
            putExtra(ChargingForegroundService.EXTRA_CHIP_TEXT, chipText)
            putExtra(ChargingForegroundService.EXTRA_REMAINING_MINUTES, remainingMinutes)
            putExtra(ChargingForegroundService.EXTRA_COMPACT_STATS, compactStats)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        } catch (e: Exception) {
            // Android 15+ caps a dataSync FGS at 6h per 24h. Once the quota is gone the start
            // is rejected; skip this update rather than crash. The service retries on next poll.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                e is ForegroundServiceStartNotAllowedException
            ) {
                Log.w(TAG, "Could not start charging service (dataSync quota exhausted)", e)
            } else {
                throw e
            }
        }
    }

    private fun stopService() {
        context.stopService(Intent(context, ChargingForegroundService::class.java))
    }
}
