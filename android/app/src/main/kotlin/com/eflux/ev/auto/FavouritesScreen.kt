package com.eflux.ev.auto

import android.text.Spannable
import android.text.SpannableString
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.DistanceSpan
import androidx.car.app.model.ItemList
import androidx.car.app.model.ListTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.Template
import android.location.Location

/**
 * Favourites screen for Android Auto.
 * Shows a list of the user's favourite stations with distances.
 * All display strings come pre-formatted from Flutter — native just renders them.
 */
class FavouritesScreen(
    carContext: CarContext,
    private val carLocation: Location?
) : Screen(carContext), FavouriteListener, UiStringsListener {

    companion object {
        private const val TAG = "FavouritesScreen"
    }

    private var favourites: List<Evse> = EvseManager.shared.favouriteEvses

    init {
        EvseManager.shared.addFavouriteListener(this)
        EvseManager.shared.addUiStringsListener(this)

        lifecycle.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
            override fun onDestroy(owner: androidx.lifecycle.LifecycleOwner) {
                Log.d(TAG, "FavouritesScreen destroyed - removing listeners")
                EvseManager.shared.removeFavouriteListener(this@FavouritesScreen)
                EvseManager.shared.removeUiStringsListener(this@FavouritesScreen)
            }
        })
    }

    override fun onFavouritesChange(favourites: List<Evse>) {
        Log.d(TAG, "Favourites updated - ${favourites.size} stations")
        this.favourites = favourites
        invalidate()
    }

    override fun onUiStringsChange() {
        Log.d(TAG, "UI strings updated - refreshing template")
        invalidate()
    }

    override fun onGetTemplate(): Template {
        Log.d(TAG, "Building favourites template with ${favourites.size} stations")

        val listBuilder = ItemList.Builder()
            .setNoItemsMessage(EvseManager.shared.uiString("noFavourites", "No favourites yet"))

        favourites.forEach { evse ->
            val distance = evse.calculateDistance(carContext, carLocation)
            val secondLineText = if (evse.summary.isNotEmpty()) {
                SpannableString("\u200B ${evse.summary}").apply {
                    setSpan(DistanceSpan.create(distance), 0, 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE)
                }
            } else {
                SpannableString(" ").apply {
                    setSpan(DistanceSpan.create(distance), 0, 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE)
                }
            }

            listBuilder.addItem(
                Row.Builder()
                    .setTitle(evse.title)
                    .addText(evse.subtitle)
                    .addText(secondLineText)
                    .setOnClickListener {
                        Log.d(TAG, "Selected favourite: ${evse.title}")
                        screenManager.push(EvseDetailScreen(carContext, evse, carLocation))
                    }
                    .build()
            )
        }

        return ListTemplate.Builder()
            .setTitle(EvseManager.shared.uiString("tabFavourites", "Favourites"))
            .setSingleList(listBuilder.build())
            .setHeaderAction(Action.BACK)
            .build()
    }
}
