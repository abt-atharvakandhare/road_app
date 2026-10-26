package com.eflux.ev.payment

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.TopAppBar
import androidx.compose.ui.Modifier
import androidx.lifecycle.lifecycleScope
import com.checkout.components.core.CheckoutComponentsFactory
import com.checkout.components.interfaces.Environment
import com.checkout.components.interfaces.api.CheckoutComponents
import com.checkout.components.interfaces.component.CheckoutComponentConfiguration
import com.checkout.components.interfaces.component.ComponentCallback
import com.checkout.components.interfaces.component.ComponentOption
import com.checkout.components.interfaces.component.GooglePayConfiguration
import com.checkout.components.interfaces.error.CheckoutErrorCode
import com.checkout.components.interfaces.localisation.ComponentTranslationKey
import com.checkout.components.interfaces.localisation.Locale
import com.checkout.components.interfaces.model.ApiCallResult
import com.checkout.components.interfaces.model.CallbackResult
import com.checkout.components.interfaces.model.CardSchemeName
import com.checkout.components.interfaces.model.CardTypeName
import com.checkout.components.interfaces.model.ComponentName
import com.checkout.components.interfaces.model.PaymentMethodName
import com.checkout.components.interfaces.model.PaymentSessionResponse
import com.checkout.components.interfaces.model.paymentsession.PaymentAction
import com.checkout.components.interfaces.model.paymentsession.PaymentSessionSubmissionResult
import com.checkout.components.interfaces.uicustomisation.designtoken.ColorTokens
import com.checkout.components.interfaces.uicustomisation.designtoken.DefaultBorderRadius
import com.checkout.components.interfaces.uicustomisation.designtoken.DesignTokens
import com.checkout.components.wallet.wrapper.GooglePayFlowCoordinator
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import org.json.JSONObject
import kotlin.coroutines.resume

class AddCardActivity : ComponentActivity() {

    companion object {
        private const val TAG = "AddCardActivity"
    }

    // Must be constructed before the activity reaches STARTED — it calls
    // `registerForActivityResult` internally. Created eagerly in `onCreate`.
    private lateinit var googlePayFlowCoordinator: GooglePayFlowCoordinator

    // Kept so the Google Pay coordinator callback can forward its activity result
    // into the SDK, which in turn drives `handleSubmit` → `onSuccess`.
    private var checkoutComponents: CheckoutComponents? = null

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        // Makes the Scaffold's TopAppBar inset under the status bar on pre-API-35 OS.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        // Coordinator registration must happen synchronously during onCreate.
        googlePayFlowCoordinator = GooglePayFlowCoordinator(this) { resultCode, data ->
            // Only log the result code — the Google Pay result payload may contain
            // tokenized payment data and must not be written to logcat (PCI / bug-report leakage).
            Log.d(TAG, "GooglePay activity result: code=$resultCode")
            checkoutComponents?.handleActivityResult(resultCode, data)
        }

        // Prevent screenshots of card details
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)

        @Suppress("UNCHECKED_CAST")
        val customerDetails = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            intent.getSerializableExtra("customerDetails", HashMap::class.java) as? HashMap<String, String>
        } else {
            @Suppress("DEPRECATION")
            intent.getSerializableExtra("customerDetails") as? HashMap<String, String>
        }

        if (customerDetails == null) {
            finishWithResult("ERROR: Customer details not provided")
            return
        }

        val publicKey = customerDetails["apiKey"]
        if (publicKey == null) {
            finishWithResult("ERROR: API key not provided")
            return
        }

        val paymentSessionId = customerDetails["paymentSessionId"]
        val paymentSessionSecret = customerDetails["paymentSessionSecret"]
        if (paymentSessionId == null || paymentSessionSecret == null) {
            finishWithResult("ERROR: Payment session data not provided")
            return
        }

        val isProduction = customerDetails["environment"] != "staging"
        val environment = if (isProduction) Environment.PRODUCTION else Environment.SANDBOX

        // Brand colour for the pay button. Dart sends 0-255 RGB components; we pack them
        // into an opaque 0xAARRGGBB long (the type ColorTokens.colorAction expects). Null
        // when any are missing, in which case we leave the SDK's default action colour.
        val brandColorArgb: Long? = run {
            val red = customerDetails["primaryColorRed"]?.toIntOrNull()
            val green = customerDetails["primaryColorGreen"]?.toIntOrNull()
            val blue = customerDetails["primaryColorBlue"]?.toIntOrNull()
            if (red != null && green != null && blue != null) {
                (0xFFL shl 24) or (red.toLong() shl 16) or (green.toLong() shl 8) or blue.toLong()
            } else {
                null
            }
        }

        // Localised pay-button label and the app's active language. We set the SDK locale
        // to match the app so the Flow UI is localised consistently, then override the
        // button label (default "Pay") for that same locale.
        val payButtonLabel = customerDetails["payButtonLabel"]
        val sdkLocale = when (customerDetails["localeCode"]) {
            "ar" -> Locale.Ar
            "da" -> Locale.Da
            "de" -> Locale.De
            "el" -> Locale.El
            "es" -> Locale.Es
            "fi" -> Locale.Fi
            "fil" -> Locale.Fil
            "fr" -> Locale.Fr
            "hi" -> Locale.Hi
            "id" -> Locale.Id
            "it" -> Locale.It
            "ja" -> Locale.Ja
            "ms" -> Locale.Ms
            "nb" -> Locale.Nb
            "nl" -> Locale.Nl
            "pt" -> Locale.Pt
            "sv" -> Locale.Sv
            "th" -> Locale.Th
            "vi" -> Locale.Vi
            "zh" -> Locale.Zh
            else -> Locale.En
        }

        lifecycleScope.launch {
            try {
                var tokenScheme = ""
                var tokenType = ""

                val callback = ComponentCallback(
                    onSubmit = { component ->
                        // onTokenized fires for cards only (TokenizationResult.type has no
                        // wallet case), so onSubmit is the only hook that exposes wallet
                        // methods. component.name.value is e.g. "Card" / "GooglePay" —
                        // normalise to "card" / "googlepay" to match Dart's typeToBeMethod.
                        val name = component.name.value.lowercase().replace(" ", "")
                        Log.d(TAG, "onSubmit: ${component.name.value} → type=$name")
                        tokenType = name
                    },
                    onTokenized = { tokenizationResult ->
                        // preferredScheme is only set when the user picks a scheme on a
                        // co-badged card; the detected scheme lives in data.scheme.
                        tokenScheme = tokenizationResult.preferredScheme
                            ?: tokenizationResult.data.scheme
                            ?: ""
                        Log.d(TAG, "onTokenized: scheme=$tokenScheme")
                        CallbackResult.Accepted
                    },
                    handleSubmit = { sessionData ->
                        Log.d(TAG, "handleSubmit: sessionData length=${sessionData.length}")
                        authorizeTokenizationViaDart(sessionData, tokenType, tokenScheme, paymentSessionId)
                    },
                    onSuccess = { _, paymentId ->
                        Log.d(TAG, "onSuccess: paymentId=$paymentId")
                        runOnUiThread { finishWithResult("SUCCESS:$paymentId") }
                    },
                    onError = { _, error ->
                        Log.e(TAG, "onError: code=${error.code} ${error.message}")
                        // Dismissing the Google Pay sheet surfaces here as PAYMENT_CANCELLED.
                        // The Flow SDK leaves its card form on screen, so swallow it: finishing
                        // the activity would close the add-card screen and flash an error in
                        // Dart for what was just a cancel. The app bar close button (or
                        // completing the card) stays the real exit. Matches iOS.
                        if (error.code == CheckoutErrorCode.PAYMENT_CANCELLED) {
                            return@ComponentCallback
                        }
                        runOnUiThread { finishWithResult("ERROR: ${error.message}") }
                    }
                )

                val paymentSessionResponse = PaymentSessionResponse(
                    id = paymentSessionId,
                    secret = paymentSessionSecret
                )

                // Override only the action (pay button) colour; leave fonts and border
                // radii at the SDK defaults so the rest of the look is unchanged. An empty
                // fonts map is safe — the SDK falls back to its own defaults per key.
                val appearance = DesignTokens(
                    colorTokens = if (brandColorArgb != null) {
                        ColorTokens(colorAction = brandColorArgb)
                    } else {
                        ColorTokens()
                    },
                    fonts = emptyMap(),
                    borderFormRadius = DefaultBorderRadius.FORM,
                    borderButtonRadius = DefaultBorderRadius.BUTTON,
                )

                val configuration = CheckoutComponentConfiguration(
                    context = this@AddCardActivity,
                    publicKey = publicKey,
                    environment = environment,
                    paymentSession = paymentSessionResponse,
                    flowCoordinators = mapOf(PaymentMethodName.GooglePay to googlePayFlowCoordinator),
                    locale = sdkLocale,
                    translations = if (payButtonLabel != null) {
                        mapOf(sdkLocale to mapOf(ComponentTranslationKey.PayButtonPay to payButtonLabel))
                    } else {
                        emptyMap()
                    },
                    appearance = appearance,
                    componentCallback = callback,
                )

                val factory = CheckoutComponentsFactory(configuration)
                val checkoutComponents = factory.create()
                this@AddCardActivity.checkoutComponents = checkoutComponents

                // Flow component renders whatever methods the payment session enables:
                // card form plus Google Pay button (when the session advertises googlepay).
                val component = checkoutComponents.create(
                    ComponentName.Flow,
                    ComponentOption(
                        showPayButton = true,
                        googlePayConfiguration = GooglePayConfiguration(
                            acceptedCardSchemes = CardSchemeName.GooglePay.entries,
                            acceptedCardTypes = CardTypeName.GooglePay.entries,
                        ),
                    ),
                )

                setContent {
                    Scaffold(
                        topBar = {
                            TopAppBar(
                                title = {},
                                navigationIcon = {
                                    IconButton(onClick = { finish() }) {
                                        Icon(
                                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                            contentDescription = "Back",
                                        )
                                    }
                                },
                            )
                        },
                    ) { paddingValues ->
                        Box(modifier = Modifier.padding(paddingValues)) {
                            component.Render()
                        }
                    }
                }
            } catch (e: Exception) {
                finishWithResult("ERROR: Failed to initialize Checkout SDK: ${e.message}")
            }
        }
    }

    /**
     * Invokes the Dart `authorizeTokenization` handler via the shared MethodChannel,
     * waits for the response, and parses it into an [ApiCallResult] the SDK can use.
     */
    private suspend fun authorizeTokenizationViaDart(
        sessionData: String,
        type: String,
        scheme: String,
        sessionId: String
    ): ApiCallResult = suspendCancellableCoroutine { continuation ->
        val channel = PaymentProcessor.channel
        if (channel == null) {
            Log.e(TAG, "PaymentProcessor.channel is null — cannot call Dart")
            continuation.resume(ApiCallResult.Failure)
            return@suspendCancellableCoroutine
        }

        // MethodChannel calls must happen on the main thread
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod(
                "authorizeTokenization",
                mapOf("sessionData" to sessionData, "type" to type, "scheme" to scheme),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        val dict = result as? Map<*, *>
                        val actionDataString = dict?.get("actionData") as? String
                        if (actionDataString == null) {
                            continuation.resume(ApiCallResult.Failure)
                            return
                        }

                        try {
                            val json = JSONObject(actionDataString)
                            val id = json.optString("id", sessionId)
                            val status = json.optString("status", "")
                            val type = json.optString("type", "card")

                            val action: PaymentAction? = json.optJSONObject("action")?.let {
                                val actionType = it.optString("type", "")
                                val actionUrl = it.optString("url", "")
                                if (actionType.isNotEmpty() && actionUrl.isNotEmpty()) {
                                    PaymentAction(actionType, actionUrl)
                                } else null
                            }

                            continuation.resume(
                                ApiCallResult.Success(
                                    PaymentSessionSubmissionResult(
                                        id = id,
                                        type = type,
                                        status = status,
                                        action = action
                                    )
                                )
                            )
                        } catch (e: Exception) {
                            Log.e(TAG, "Failed to parse actionData: ${e.message}")
                            continuation.resume(ApiCallResult.Failure)
                        }
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        Log.e(TAG, "Dart authorizeTokenization error: $errorCode $errorMessage")
                        continuation.resume(ApiCallResult.Failure)
                    }

                    override fun notImplemented() {
                        Log.e(TAG, "Dart did not implement authorizeTokenization")
                        continuation.resume(ApiCallResult.Failure)
                    }
                }
            )
        }
    }

    override fun onDestroy() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onDestroy()
    }

    private fun finishWithResult(result: String) {
        val intent = Intent()
        intent.putExtra("tokenResult", result)
        setResult(RESULT_OK, intent)
        finish()
    }
}
