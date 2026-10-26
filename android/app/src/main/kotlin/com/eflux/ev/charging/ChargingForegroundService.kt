package com.eflux.ev.charging

import android.app.ForegroundServiceStartNotAllowedException
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.RelativeSizeSpan
import android.util.Log
import androidx.core.app.NotificationCompat
import com.eflux.ev.MainActivity
import com.eflux.ev.R

/**
 * Long-running foreground service that keeps the app's charging session notification
 * visible while a session is active. The notification itself is the FGS's user-visible
 * indicator so it shows without the POST_NOTIFICATIONS runtime permission.
 *
 * The service is stateless — it only renders whatever values the Flutter side sent in
 * the most recent start/update intent. Dart owns the polling loop and passes new values
 * via the `io.e-flux.mobile/chargingService` method channel.
 */
class ChargingForegroundService : Service() {

    companion object {
        private const val TAG = "ChargingForegroundService"

        const val ACTION_START_OR_UPDATE = "com.eflux.ev.charging.START_OR_UPDATE"

        const val EXTRA_LOCATION_NAME = "locationName"
        const val EXTRA_PRIMARY_METRIC = "primaryMetric"
        const val EXTRA_STAT_PRIMARY = "statPrimary"
        const val EXTRA_STAT_SECONDARY = "statSecondary"
        const val EXTRA_SUBTITLE = "subtitle"
        const val EXTRA_PROGRESS = "progress" // 0-100, negative = hide
        const val EXTRA_COLLAPSED_TITLE = "collapsedTitle"
        const val EXTRA_CHIP_TEXT = "chipText" // single-line status-bar chip text on API 36+
        const val EXTRA_REMAINING_MINUTES = "remainingMinutes" // -1 = unknown
        const val EXTRA_COMPACT_STATS = "compactStats" // unlabeled stats for API 36+ header line

        private const val CHANNEL_ID = "charging_session"
        private const val CHANNEL_NAME = "Charging Session"
        private const val NOTIFICATION_ID = 4211

        // Right edge of the Figma yellow→green progress gradient. Used as the
        // single-segment fill on API 36+; stepped-gradient is a fast-follow.
        private const val PROGRESS_BAR_COLOR = 0xFF00F10A.toInt()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification(intent)
        try {
            // On Android 14+ (API 34) the foregroundServiceType argument is required at the
            // call site, not just in the manifest. Passing it explicitly keeps us compatible
            // with the system's 5-second start-foreground deadline.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            // Android 15+ caps a dataSync FGS at 6h per 24h. Once exhausted, startForeground
            // throws ForegroundServiceStartNotAllowedException; stop cleanly rather than crash.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                e is ForegroundServiceStartNotAllowedException
            ) {
                Log.w(TAG, "Foreground start rejected (dataSync quota exhausted); stopping", e)
                stopSelf(startId)
                return START_NOT_STICKY
            }
            throw e
        }
        // Restart-behaviour: if the system kills us, Dart will re-issue start on next poll.
        return START_NOT_STICKY
    }

    // Android 15+ (API 35) calls this when the dataSync time budget is used up. We must stop
    // promptly or the system throws ForegroundServiceDidNotStopInTimeException and kills us.
    // The budget can't be extended; the notification simply ends until the quota resets.
    override fun onTimeout(startId: Int, fgsType: Int) {
        Log.w(TAG, "Foreground service timed out (type $fgsType); stopping")
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf(startId)
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            // DEFAULT (not LOW) so that the notification appears on the lock screen under
            // Android's default "Hide silent notifications on lock screen" setting. Repeated
            // updates suppress heads-up via setOnlyAlertOnce(true) on the notification itself.
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Shown while a charging session is active."
            setShowBadge(false)
            enableVibration(false)
            setSound(null, null)
            // Show full contents on the lock screen (matches the per-notification setting).
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(intent: Intent?): Notification {
        val locationName = intent?.getStringExtra(EXTRA_LOCATION_NAME)
        val primaryMetric = intent?.getStringExtra(EXTRA_PRIMARY_METRIC) ?: ""
        val statPrimary = intent?.getStringExtra(EXTRA_STAT_PRIMARY)
        val statSecondary = intent?.getStringExtra(EXTRA_STAT_SECONDARY)
        val subtitle = intent?.getStringExtra(EXTRA_SUBTITLE)
        val progress = intent?.getIntExtra(EXTRA_PROGRESS, -1) ?: -1
        val collapsedTitle = intent?.getStringExtra(EXTRA_COLLAPSED_TITLE) ?: primaryMetric
        val chipText = intent?.getStringExtra(EXTRA_CHIP_TEXT) ?: collapsedTitle
        val remainingMinutes = intent?.getIntExtra(EXTRA_REMAINING_MINUTES, -1) ?: -1
        val compactStats = intent?.getStringExtra(EXTRA_COMPACT_STATS)

        // ProgressStyle requires a progress value. When we don't have SOC we fall back
        // to the legacy BigTextStyle path even on API 36+.
        val canPromote = Build.VERSION.SDK_INT >= 36 && progress in 0..100

        return if (canPromote) {
            buildPromotedNotification(
                locationName = locationName,
                primaryMetric = primaryMetric,
                compactStats = compactStats,
                progress = progress,
                chipText = chipText,
                remainingMinutes = remainingMinutes,
            )
        } else {
            buildLegacyNotification(
                locationName = locationName,
                statPrimary = statPrimary,
                statSecondary = statSecondary,
                subtitle = subtitle,
                progress = progress,
                collapsedTitle = collapsedTitle,
            )
        }
    }

    private fun buildLegacyNotification(
        locationName: String?,
        statPrimary: String?,
        statSecondary: String?,
        subtitle: String?,
        progress: Int,
        collapsedTitle: String,
    ): Notification {
        val appName = getString(R.string.app_name)
        val bodyLines = listOfNotNull(statPrimary, statSecondary, subtitle)
            .joinToString(separator = "\n")

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.notification_icon)
            .setContentTitle("$appName — $collapsedTitle")
            .setContentText(locationName ?: "Charging")
            .setStyle(NotificationCompat.BigTextStyle().bigText(bodyLines.ifBlank { "Charging" }))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(openAppIntent())
            // DEFAULT so that the lock screen shows it. OnlyAlertOnce prevents every update
            // from re-popping a heads-up banner — only the first post alerts.
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            // Show the full notification contents on the lock screen.
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        if (progress in 0..100) {
            builder.setProgress(100, progress, false)
        }

        return builder.build()
    }

    // Android 16 (API 36) Live Update / promoted-ongoing path. Uses the platform
    // Notification.Builder directly because androidx.core's NotificationCompat
    // shims for ProgressStyle / setRequestPromotedOngoing are not yet stable.
    // Promotion is a hint — the system decides whether to render the chip. If
    // it declines, this still renders as a regular ongoing notification.
    @android.annotation.SuppressLint("NewApi")
    private fun buildPromotedNotification(
        locationName: String?,
        primaryMetric: String,
        compactStats: String?,
        progress: Int,
        chipText: String,
        remainingMinutes: Int,
    ): Notification {
        // ProgressStyle owns its own template — only specific slots render. Map our
        // content to: contentTitle (big metric AND inline stats via a relative-size
        // span), contentText (location), subText (remaining-time when known).
        // Single-line title rendering avoids the header-line truncation we saw
        // with the stats-in-subText approach.
        val titleText = buildTitleWithStats(primaryMetric.ifBlank { getString(R.string.app_name) }, compactStats)
        val subTextLine = formatHm(remainingMinutes)?.let { "$it left" }

        val progressStyle = Notification.ProgressStyle()
            .setProgress(progress)
            .setProgressSegments(listOf(Notification.ProgressStyle.Segment(100).setColor(PROGRESS_BAR_COLOR)))
            .setProgressTrackerIcon(Icon.createWithResource(this, R.mipmap.notification_icon))

        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.notification_icon)
            // Big metric (e.g. "37%") + smaller inline stats — single-line title.
            .setContentTitle(titleText)
            .setContentText(locationName ?: "Charging")
            .also { if (subTextLine != null) it.setSubText(subTextLine) }
            .setStyle(progressStyle)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false) // Hide the auto "now" timestamp — duration is already in the title.
            .setContentIntent(openAppIntent())
            .setColor(PROGRESS_BAR_COLOR)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            // Request status-bar chip promotion; system may grant or deny based on
            // hasPromotableCharacteristics(). API 36 exposes the promotion request
            // as Notification.FLAG_PROMOTED_ONGOING — there's no Builder.setRequest…
            // method despite what the AndroidX docs imply.
            .setFlag(Notification.FLAG_PROMOTED_ONGOING, true)
            // Sentence-style chip text per Figma: "37% charged. 2h 35mins remaining".
            .setShortCriticalText(chipText)
            .build()
    }

    // Builds "81%  14 mins · 5.1 kWh" where the stats portion is ~55% the size of
    // the leading metric. Keeps the SOC visually dominant while surfacing the
    // duration/energy stats on the same line.
    private fun buildTitleWithStats(metric: CharSequence, stats: String?): CharSequence {
        if (stats.isNullOrBlank()) return metric
        return SpannableStringBuilder(metric).apply {
            val statsStart = length
            append("  ")
            append(stats)
            setSpan(
                RelativeSizeSpan(0.55f),
                statsStart,
                length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
            )
        }
    }

    private fun openAppIntent(): PendingIntent {
        // ACTION_VIEW + a `road://charging` data URI lets the `app_links`
        // Flutter plugin pick the tap up via `Intent.getDataString()` on both
        // cold launch and onNewIntent. The Dart-side AppLinksCubit recognises
        // the `charging` host and opens the charging status screen — mirroring
        // the iOS Live Activity widgetURL flow.
        //
        // The `road` scheme is intentionally fixed across all white-label
        // flavors: the Intent targets MainActivity explicitly so it never
        // crosses an app boundary (no manifest <intent-filter> involved), and
        // AppLinksCubit._processAppLink keys on `host`, not scheme. If anyone
        // later adds scheme-based filtering in AppLinksCubit, either parameterise
        // this from the flavor or update that check.
        val intent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse("road://charging")
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
