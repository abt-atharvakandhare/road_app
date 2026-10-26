package com.eflux.ev.payment

import android.app.Activity
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

/**
 * Handles payment method channel communication and payment processing
 */
class PaymentProcessor(
    private val activity: Activity,
    flutterEngine: FlutterEngine
) {

    companion object {
        // Channel name
        private const val CHANNEL_NAME = "io.e-flux.mobile/payments"

        // Method names
        private const val ADD_PAYMENT_CARD_METHOD = "addPaymentCard"
        private const val PERFORM_THREE_DS_METHOD = "performThreeDS"

        // Activity request codes
        const val ENTER_CARD_DETAILS_CODE = 1001
        const val THREE_DS_CODE = 1002

        // Intent extras
        const val CUSTOMER_DETAILS_EXTRA = "customerDetails"
        const val ARGUMENTS_EXTRA = "arguments"
        const val TOKEN_RESULT_EXTRA = "tokenResult"

        // Log tag
        private const val TAG = "PaymentProcessor"

        /** Shared channel so [AddCardActivity] can invoke methods back on Dart. */
        var channel: MethodChannel? = null
            private set
    }

    var resultHandler: MethodChannel.Result? = null
        private set

    init {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                ADD_PAYMENT_CARD_METHOD -> handleAddPaymentCard(call, result)
                PERFORM_THREE_DS_METHOD -> handlePerformThreeDS(call, result)
                else -> result.notImplemented()
            }
        }
    }
    
    private fun handleAddPaymentCard(call: MethodCall, result: MethodChannel.Result) {
        resultHandler = result
        
        val customerDetails = call.arguments as? HashMap<String, String>
        if (customerDetails == null) {
            Log.e(TAG, "Invalid customer details provided")
            result.error("INVALID_ARGUMENTS", "Customer details must be provided", null)
            return
        }
        
        val intent = Intent(activity, AddCardActivity::class.java).apply {
            putExtra(CUSTOMER_DETAILS_EXTRA, customerDetails)
        }
        
        activity.startActivityForResult(intent, ENTER_CARD_DETAILS_CODE)
        Log.d(TAG, "Started AddCardActivity")
    }
    
    private fun handlePerformThreeDS(call: MethodCall, result: MethodChannel.Result) {
        resultHandler = result
        
        val arguments = call.arguments as? HashMap<String, String>
        if (arguments == null) {
            Log.e(TAG, "Invalid 3DS arguments provided")
            result.error("INVALID_ARGUMENTS", "3DS arguments must be provided", null)
            return
        }
        
        val intent = Intent(activity, ThreeDsActivity::class.java).apply {
            putExtra(ARGUMENTS_EXTRA, arguments)
        }
        
        activity.startActivityForResult(intent, THREE_DS_CODE)
        Log.d(TAG, "Started ThreeDsActivity")
    }
    
    /**
     * Handle activity result from payment activities
     * Call this from MainActivity's onActivityResult
     */
    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return when (requestCode) {
            ENTER_CARD_DETAILS_CODE -> {
                // Back press / swipe dismiss finishes with RESULT_CANCELED and no extras.
                // Map that to "CANCELLED" so Dart can treat it as a graceful cancel rather
                // than an error (null → platform failed).
                val tokenResult = data?.getStringExtra(TOKEN_RESULT_EXTRA) ?: "CANCELLED"
                Log.d(TAG, "Received token result from AddCardActivity: ${tokenResult.take(10)}...")
                resultHandler?.success(tokenResult)
                resultHandler = null
                true
            }
            THREE_DS_CODE -> {
                val tokenResult = data?.getStringExtra(TOKEN_RESULT_EXTRA) ?: "CANCELLED"
                Log.d(TAG, "Received token result from ThreeDsActivity: $tokenResult")
                resultHandler?.success(tokenResult)
                resultHandler = null
                true
            }
            else -> false
        }
    }
}