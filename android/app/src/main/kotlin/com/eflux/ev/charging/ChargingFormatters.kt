package com.eflux.ev.charging

import java.util.Currency
import java.util.Locale

// Pure formatting helpers shared between the Android 16 promoted-ongoing
// notification builder ([ChargingForegroundService]) and the Dart→Android
// bridge ([ChargingServiceProcessor]). Kept top-level so they're easy to
// unit-test without instantiating the FGS or method-channel plumbing.
//
// Number formatting is locked to [Locale.ROOT] so it stays consistent with
// the hardcoded English unit suffixes ("kWh") and currency symbols. Without
// this, `%.1f` would render `5,1 kWh` on Dutch / German locales.

/**
 * Compact `Xh Ym` / `Ym` / `Xh` formatting of a minute count.
 * Returns null when [minutes] is non-positive — caller decides whether to omit
 * the value or render a fallback.
 *
 * Examples: `5 → "5m"`, `60 → "1h"`, `83 → "1h 23m"`, `0 → null`.
 */
internal fun formatHm(minutes: Int): String? {
    if (minutes <= 0) return null
    val hours = minutes / 60
    val mins = minutes % 60
    return when {
        hours == 0 -> "${mins}m"
        mins == 0 -> "${hours}h"
        else -> "${hours}h ${mins}m"
    }
}

/**
 * Integer-minute duration between [startedAtMs] and [nowMs], clamped to ≥ 0.
 * [nowMs] defaults to wall-clock time but is injectable for tests.
 */
internal fun durationMinutes(startedAtMs: Long, nowMs: Long = System.currentTimeMillis()): Int =
    ((nowMs - startedAtMs) / 60_000).toInt().coerceAtLeast(0)

/**
 * Symbol-prefixed monetary value from minor units (cents). Returns null when
 * [cents] is non-positive so callers can omit the field rather than print a
 * zero value.
 *
 * The currency symbol is resolved via [Currency.getInstance] with [Locale.US]
 * so major currencies render with their glyph (`€`, `$`, `£`, `¥`) and the
 * long tail falls back to the ISO code (`NOK 0.99`, `CHF 12.50`). Invalid
 * codes fall back to the uppercased input string.
 */
internal fun formatCost(cents: Int, currency: String): String? {
    if (cents <= 0) return null
    val code = currency.uppercase()
    val symbol = try {
        Currency.getInstance(code).getSymbol(Locale.US).ifEmpty { code }
    } catch (_: IllegalArgumentException) {
        code
    }
    // Real glyph symbols sit flush with the number ("€1.23"); alphabetic
    // fallbacks ("NOK", "CHF") get a space so they don't fuse with digits.
    val separator = if (symbol.last().isLetter()) " " else ""
    val amount = cents / 100.0
    return "%s%s%.2f".format(Locale.ROOT, symbol, separator, amount)
}

/**
 * `X.X kWh` formatting from a watt-hour input. Example: `5100.0 → "5.1 kWh"`.
 */
internal fun formatKwh(watthours: Double): String = "%.1f kWh".format(Locale.ROOT, watthours / 1000.0)

/**
 * Sentence-style chip text for the Android 16 promoted-ongoing notification.
 *
 * - SOC known: `"37% charged"` (+ `. 1h 23m remaining` when [remainingMinutes] > 0)
 * - SOC unknown, meaningful kWh: `"5.1 kWh charged"`
 * - Both effectively zero (session just started): `"Charging…"`
 *
 * The 100 Wh threshold (0.1 kWh) matches the 1-dp resolution of [formatKwh] —
 * anything smaller would render as `"0.0 kWh charged"` which reads as broken.
 */
internal fun buildChipText(stateOfCharge: Int?, energyWh: Double, remainingMinutes: Int): String {
    val primary = when {
        stateOfCharge != null -> "$stateOfCharge% charged"
        energyWh >= 100.0 -> "${formatKwh(energyWh)} charged"
        else -> "Charging…"
    }
    val remaining = formatHm(remainingMinutes) ?: return primary
    // Avoid "…. " when joining to the ellipsis fallback — space is enough.
    val separator = if (primary.endsWith("…")) " " else ". "
    return "$primary$separator$remaining remaining"
}
