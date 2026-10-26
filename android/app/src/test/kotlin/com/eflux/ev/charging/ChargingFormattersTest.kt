package com.eflux.ev.charging

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ChargingFormattersTest {

    // ----- formatHm ------------------------------------------------------------------------------

    @Test fun `formatHm returns null for zero`() {
        assertNull(formatHm(0))
    }

    @Test fun `formatHm returns null for negative`() {
        assertNull(formatHm(-5))
    }

    @Test fun `formatHm formats minutes-only`() {
        assertEquals("5m", formatHm(5))
        assertEquals("59m", formatHm(59))
    }

    @Test fun `formatHm formats whole hours without trailing zero minutes`() {
        assertEquals("1h", formatHm(60))
        assertEquals("2h", formatHm(120))
    }

    @Test fun `formatHm formats hours and minutes`() {
        assertEquals("1h 23m", formatHm(83))
        assertEquals("10h 1m", formatHm(601))
    }

    // ----- durationMinutes -----------------------------------------------------------------------

    @Test fun `durationMinutes computes elapsed minutes`() {
        val start = 1_000_000_000L
        val now = start + 5 * 60_000 + 30_000 // 5.5 minutes later
        assertEquals(5, durationMinutes(start, now))
    }

    @Test fun `durationMinutes clamps negative to zero`() {
        val start = 1_000_000_000L
        assertEquals(0, durationMinutes(start, start - 60_000))
    }

    @Test fun `durationMinutes returns zero for same instant`() {
        val start = 1_000_000_000L
        assertEquals(0, durationMinutes(start, start))
    }

    // ----- formatCost ----------------------------------------------------------------------------

    @Test fun `formatCost returns null for zero or negative`() {
        assertNull(formatCost(0, "EUR"))
        assertNull(formatCost(-100, "EUR"))
    }

    @Test fun `formatCost renders EUR with euro symbol`() {
        assertEquals("€1.23", formatCost(123, "EUR"))
        assertEquals("€12.45", formatCost(1245, "eur"))
    }

    @Test fun `formatCost renders GBP and USD`() {
        assertEquals("£1.00", formatCost(100, "GBP"))
        assertEquals("$0.99", formatCost(99, "USD"))
    }

    @Test fun `formatCost renders JPY with yen glyph`() {
        assertEquals("¥1.23", formatCost(123, "JPY"))
    }

    @Test fun `formatCost falls back to ISO code with space for currencies without an en-US glyph`() {
        assertEquals("NOK 0.99", formatCost(99, "NOK"))
        assertEquals("CHF 12.50", formatCost(1250, "CHF"))
    }

    @Test fun `formatCost falls back gracefully for invalid currency codes`() {
        assertEquals("ABC 1.00", formatCost(100, "ABC"))
        assertEquals("ZZZ 0.50", formatCost(50, "ZZZ"))
    }

    // ----- formatKwh -----------------------------------------------------------------------------

    @Test fun `formatKwh converts watt-hours to kWh with one decimal`() {
        assertEquals("5.1 kWh", formatKwh(5100.0))
        assertEquals("0.0 kWh", formatKwh(0.0))
        assertEquals("12.5 kWh", formatKwh(12_500.0))
    }

    // ----- buildChipText -------------------------------------------------------------------------

    @Test fun `buildChipText prefers SOC when known`() {
        assertEquals("37% charged", buildChipText(stateOfCharge = 37, energyWh = 5100.0, remainingMinutes = -1))
    }

    @Test fun `buildChipText falls back to kWh when SOC is unknown`() {
        assertEquals("5.1 kWh charged", buildChipText(stateOfCharge = null, energyWh = 5100.0, remainingMinutes = -1))
    }

    @Test fun `buildChipText appends remaining when known`() {
        assertEquals(
            "37% charged. 1h 23m remaining",
            buildChipText(stateOfCharge = 37, energyWh = 5100.0, remainingMinutes = 83),
        )
    }

    @Test fun `buildChipText drops remaining clause when minutes is non-positive`() {
        assertEquals("37% charged", buildChipText(stateOfCharge = 37, energyWh = 5100.0, remainingMinutes = 0))
        assertEquals("37% charged", buildChipText(stateOfCharge = 37, energyWh = 5100.0, remainingMinutes = -5))
    }

    @Test fun `buildChipText shows Charging fallback when SOC unknown and energy near zero`() {
        assertEquals("Charging…", buildChipText(stateOfCharge = null, energyWh = 0.0, remainingMinutes = -1))
        assertEquals("Charging…", buildChipText(stateOfCharge = null, energyWh = 50.0, remainingMinutes = -1))
    }

    @Test fun `buildChipText joins remaining to Charging fallback with a space, not a period`() {
        assertEquals(
            "Charging… 5m remaining",
            buildChipText(stateOfCharge = null, energyWh = 0.0, remainingMinutes = 5),
        )
    }
}
