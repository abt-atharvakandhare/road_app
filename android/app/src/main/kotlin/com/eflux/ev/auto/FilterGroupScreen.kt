package com.eflux.ev.auto

import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.ItemList
import androidx.car.app.model.ListTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.Template

/**
 * Sub-screen for a filter group (singleChoice or multipleChoice).
 * Shows the group's children as selectable rows with checkmarks.
 * Listens for filter updates from Flutter to refresh in real-time.
 */
class FilterGroupScreen(
    carContext: CarContext,
    private val groupKey: String
) : Screen(carContext), FilterListener, UiStringsListener {

    companion object {
        private const val TAG = "FilterGroupScreen"
    }

    init {
        EvseManager.shared.addFilterListener(this)
        EvseManager.shared.addUiStringsListener(this)

        lifecycle.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
            override fun onDestroy(owner: androidx.lifecycle.LifecycleOwner) {
                Log.d(TAG, "FilterGroupScreen destroyed - removing listeners")
                EvseManager.shared.removeFilterListener(this@FilterGroupScreen)
                EvseManager.shared.removeUiStringsListener(this@FilterGroupScreen)
            }
        })
    }

    override fun onFilterItemsChange(filterItems: List<CarScreenFilterItem>) {
        Log.d(TAG, "Filter items updated - refreshing group $groupKey")
        invalidate()
    }

    override fun onUiStringsChange() {
        Log.d(TAG, "UI strings updated - refreshing template")
        invalidate()
    }

    override fun onGetTemplate(): Template {
        val group = EvseManager.shared.filterGroup(groupKey)

        if (group == null) {
            Log.e(TAG, "Group not found for key: $groupKey")
            return ListTemplate.Builder()
                .setTitle(groupKey)
                .setSingleList(ItemList.Builder().build())
                .setHeaderAction(Action.BACK)
                .build()
        }

        Log.d(TAG, "Building group template for ${group.label} with ${group.children.size} children")

        val listBuilder = ItemList.Builder()

        // For singleChoice groups, add an "All" option that clears all selections
        if (group.type == "singleChoice") {
            val noneSelected = group.children.all { !it.selected }
            listBuilder.addItem(
                Row.Builder()
                    .setTitle(EvseManager.shared.uiString("all", "All"))
                    .addText(if (noneSelected) "✓" else "")
                    .setOnClickListener {
                        Log.d(TAG, "'All' tapped for group ${group.key}")
                        // Turn off all children in this group
                        for (child in group.children) {
                            if (child.selected) {
                                AndroidAutoProcessor.getInstance()?.toggleCarScreenFilter(child.key, false)
                            }
                        }
                    }
                    .build()
            )
        }

        for (child in group.children) {
            listBuilder.addItem(
                Row.Builder()
                    .setTitle(child.label)
                    .addText(if (child.selected) "✓" else "")
                    .setOnClickListener {
                        val newSelected = !child.selected
                        Log.d(TAG, "Group child toggled - ${child.key} -> $newSelected")
                        AndroidAutoProcessor.getInstance()?.toggleCarScreenFilter(child.key, newSelected)
                    }
                    .build()
            )
        }

        return ListTemplate.Builder()
            .setTitle(group.label)
            .setSingleList(listBuilder.build())
            .setHeaderAction(Action.BACK)
            .build()
    }
}
