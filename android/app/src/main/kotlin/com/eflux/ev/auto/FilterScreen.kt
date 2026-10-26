package com.eflux.ev.auto

import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.ItemList
import androidx.car.app.model.ListTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.SectionedItemList
import androidx.car.app.model.Template

/**
 * Filter screen for Android Auto.
 * Shows a list of filter toggles and drill-down groups built from definitions received from Flutter.
 * All labels come pre-formatted from Flutter — native just renders them.
 */
class FilterScreen(
    carContext: CarContext
) : Screen(carContext), FilterListener, HighwayModeListener, UiStringsListener {

    companion object {
        private const val TAG = "FilterScreen"
    }

    private var filterItems: List<CarScreenFilterItem> = EvseManager.shared.filterItems
    private var highwayMode: String = EvseManager.shared.highwayMode

    init {
        EvseManager.shared.addFilterListener(this)
        EvseManager.shared.addModeListener(this)
        EvseManager.shared.addUiStringsListener(this)

        lifecycle.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
            override fun onDestroy(owner: androidx.lifecycle.LifecycleOwner) {
                Log.d(TAG, "FilterScreen destroyed - removing listeners")
                EvseManager.shared.removeFilterListener(this@FilterScreen)
                EvseManager.shared.removeModeListener(this@FilterScreen)
                EvseManager.shared.removeUiStringsListener(this@FilterScreen)
            }
        })
    }

    override fun onFilterItemsChange(filterItems: List<CarScreenFilterItem>) {
        Log.d(TAG, "Filter items updated - ${filterItems.size} definitions")
        this.filterItems = filterItems
        invalidate()
    }

    override fun onHighwayModeChange(isHighwayModeActive: Boolean, highwayMode: String) {
        Log.d(TAG, "Highway mode changed - mode: $highwayMode")
        this.highwayMode = highwayMode
        invalidate()
    }

    override fun onUiStringsChange() {
        Log.d(TAG, "UI strings updated - refreshing template")
        invalidate()
    }

    override fun onGetTemplate(): Template {
        Log.d(TAG, "Building filter template with ${filterItems.size} filter items")

        // Section 1: Highway mode (separate from filters)
        val highwayLabel = when (highwayMode) {
            "off" -> EvseManager.shared.uiString("highwayOff", "Highway mode: Off")
            "on" -> EvseManager.shared.uiString("highwayOn", "Highway mode: On")
            else -> EvseManager.shared.uiString("highwayAuto", "Highway mode: Auto")
        }
        val highwayList = ItemList.Builder()
            .addItem(
                Row.Builder()
                    .setTitle(EvseManager.shared.uiString("highway", "Highway mode"))
                    .addText(highwayLabel)
                    .setOnClickListener {
                        Log.d(TAG, "Highway mode tapped - cycling from $highwayMode")
                        AndroidAutoProcessor.getInstance()?.toggleHighwayMode()
                    }
                    .build()
            )
            .build()

        // Section 2: Filters
        val filterListBuilder = ItemList.Builder()
            .setNoItemsMessage(EvseManager.shared.uiString("noFiltersAvailable", "No filters available"))

        val onLabel = EvseManager.shared.uiString("filterOn", "On")
        val offLabel = EvseManager.shared.uiString("filterOff", "Off")

        for (item in filterItems) {
            when (item) {
                is CarScreenFilterItem.Toggle -> {
                    val filter = item.filter
                    filterListBuilder.addItem(
                        Row.Builder()
                            .setTitle(filter.label)
                            .addText(if (filter.enabled) onLabel else offLabel)
                            .setOnClickListener {
                                val newEnabled = !filter.enabled
                                Log.d(TAG, "Filter toggled - ${filter.key} -> $newEnabled")
                                AndroidAutoProcessor.getInstance()?.toggleCarScreenFilter(filter.key, newEnabled)
                            }
                            .build()
                    )
                }
                is CarScreenFilterItem.Group -> {
                    val group = item.group
                    filterListBuilder.addItem(
                        Row.Builder()
                            .setTitle(group.label)
                            .addText(group.selectedLabel)
                            .setBrowsable(true)
                            .setOnClickListener {
                                Log.d(TAG, "Group tapped - ${group.key}")
                                screenManager.push(FilterGroupScreen(carContext, group.key))
                            }
                            .build()
                    )
                }
            }
        }

        val highwayHeader = EvseManager.shared.uiString("highway", "Highway mode")
        val filtersHeader = EvseManager.shared.uiString("filters", "Filters")

        val templateBuilder = ListTemplate.Builder()
            .setTitle(EvseManager.shared.uiString("tabFilters", "Filters"))
            .addSectionedList(SectionedItemList.create(highwayList, highwayHeader))

        if (filterItems.isNotEmpty()) {
            templateBuilder.addSectionedList(SectionedItemList.create(filterListBuilder.build(), filtersHeader))
        }

        return templateBuilder
            .setHeaderAction(Action.BACK)
            .build()
    }
}
