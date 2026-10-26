package com.eflux.ev.auto

import android.text.Spannable
import android.text.SpannableString
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.ScreenManager
import androidx.car.app.model.Action
import androidx.car.app.model.CarColor
import androidx.car.app.model.DistanceSpan
import androidx.car.app.model.Pane
import androidx.car.app.model.PaneTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.Template
import android.location.Location

/**
 * Detail screen for a selected EVSE charging station.
 * Uses PaneTemplate for lozenge-style action buttons at the bottom.
 * Connector rows are combined into a single row to stay within
 * PaneTemplate's 4-row limit.
 * All display strings come pre-formatted from Flutter — native just renders them.
 */
class EvseDetailScreen(
    carContext: CarContext,
    private val evse: Evse,
    private val carLocation: Location?
) : Screen(carContext), UiStringsListener {

    companion object {
        private const val TAG = "EvseDetailScreen"
    }

    private var isFavourite: Boolean = evse.isFavourite

    init {
        EvseManager.shared.addUiStringsListener(this)

        lifecycle.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
            override fun onDestroy(owner: androidx.lifecycle.LifecycleOwner) {
                Log.d(TAG, "EvseDetailScreen destroyed - removing listener")
                EvseManager.shared.removeUiStringsListener(this@EvseDetailScreen)
            }
        })
    }

    override fun onUiStringsChange() {
        Log.d(TAG, "UI strings updated - refreshing template")
        invalidate()
    }

    override fun onGetTemplate(): Template {
        Log.d(TAG, "Building details template for: ${evse.title}")

        val distance = evse.calculateDistance(carContext, carLocation)

        val paneBuilder = Pane.Builder()

        // Address row with distance
        if (evse.addressText.isNotEmpty()) {
            paneBuilder.addRow(
                Row.Builder()
                    .setTitle(evse.addressText)
                    .addText(SpannableString(" ").apply {
                        setSpan(
                            DistanceSpan.create(distance),
                            0,
                            1,
                            Spannable.SPAN_INCLUSIVE_INCLUSIVE
                        )
                    })
                    .build()
            )
        }

        // Connector rows combined into a single row
        if (evse.connectorRows.isNotEmpty()) {
            val connectorTitle = evse.connectorRows.mapNotNull { it["title"] }.joinToString(" · ")
            val connectorDetail = evse.connectorRows.mapNotNull { it["detail"] }.joinToString(" · ")
            val rowBuilder = Row.Builder().setTitle(connectorTitle)
            if (connectorDetail.isNotEmpty()) {
                rowBuilder.addText(connectorDetail)
            }
            paneBuilder.addRow(rowBuilder.build())
        }

        // Price row
        if (evse.priceText.isNotEmpty()) {
            paneBuilder.addRow(
                Row.Builder()
                    .setTitle(evse.priceText)
                    .build()
            )
        }

        // Navigate action button (primary)
        paneBuilder.addAction(
            Action.Builder()
                .setTitle(EvseManager.shared.uiString("navigate", "Navigate"))
                .setBackgroundColor(CarColor.PRIMARY)
                .setOnClickListener {
                    Log.d(TAG, "Navigate clicked for ${evse.title}")
                    if (!evse.navigateWithCarContext(carContext)) {
                        carContext.getCarService(ScreenManager::class.java).push(
                            MapScreen.buildNavigationErrorScreen(carContext, evse)
                        )
                    }
                }
                .build()
        )

        // Favourite action button (secondary)
        if (evse.favouriteButtonLabel.isNotEmpty()) {
            val favLabel = if (isFavourite) {
                EvseManager.shared.uiString("saved", "❤️ Saved")
            } else {
                EvseManager.shared.uiString("save", "🤍 Save")
            }
            paneBuilder.addAction(
                Action.Builder()
                    .setTitle(favLabel)
                    .setOnClickListener {
                        Log.d(TAG, "Favourite toggled for ${evse.title}")
                        AndroidAutoProcessor.getInstance()?.toggleFavourite(evse.id)
                        isFavourite = !isFavourite
                        invalidate()
                    }
                    .build()
            )
        }

        return PaneTemplate.Builder(paneBuilder.build())
            .setTitle(evse.title)
            .setHeaderAction(Action.BACK)
            .build()
    }
}
