package com.eflux.ev.payment

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity

class ThreeDsActivity : ComponentActivity() {
    companion object {
        private const val TAG = "ThreeDsActivity"
        private const val SUCCESS_URL = "https://success.payment.complete/"
        private const val FAILURE_URL = "https://failure.payment.complete/"
    }

    @Suppress("UNCHECKED_CAST")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val arguments = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            intent.getSerializableExtra("arguments", HashMap::class.java) as? HashMap<String, String>
        } else {
            @Suppress("DEPRECATION")
            intent.getSerializableExtra("arguments") as? HashMap<String, String>
        }

        if (arguments == null) {
            finishWithResult("ERROR: 3DS arguments not provided")
            return
        }

        val threeDsUrl = arguments["threeDsUrl"]
        if (threeDsUrl == null) {
            finishWithResult("ERROR: 3DS URL not provided")
            return
        }

        val webView = WebView(this)
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                val url = request?.url?.toString() ?: return false

                if (url.startsWith(SUCCESS_URL)) {
                    Log.d(TAG, "3DS succeeded")
                    finishWithResult("SUCCESS")
                    return true
                }

                if (url.startsWith(FAILURE_URL)) {
                    Log.d(TAG, "3DS failed")
                    finishWithResult("ERROR: 3DS failed.")
                    return true
                }

                return false
            }
        }

        setContentView(webView)
        webView.loadUrl(threeDsUrl)
    }

    private fun finishWithResult(result: String) {
        val intent = Intent()
        intent.putExtra("tokenResult", result)
        setResult(RESULT_OK, intent)
        finish()
    }
}
