//
//  PaymentProcessor.swift
//  Runner
//
//  Created by Ray Hunter on 09/11/2023.
//

import Foundation
import CheckoutComponentsSDK
import SwiftUI
import WebKit

class PaymentProcessor: NSObject {
    // MARK: - Constants
    private struct Constants {
        static let channelName = "io.e-flux.mobile/payments"

        // Method names
        static let addPaymentCardMethod = "addPaymentCard"
        static let performThreeDSMethod = "performThreeDS"

        // Error codes and messages
        static let errorPrefix = "ERROR: "
        static let cancelledResponse = "CANCELLED"
        static let badArgumentsError = "ERROR: bad add card arguments"
        static let apiKeyError = "ERROR: API key not provided"
        static let badThreeDSArgumentsError = "ERROR: bad 3DS arguments"
        static let threeDSUrlError = "ERROR: 3DS URL not provided"
        static let threeDSUrlInvalidError = "ERROR: 3DS URL not valid"
        static let threeDSSuccessNoTokenError = "ERROR: 3DS was successful, however no token was provided."
        static let threeDSFailedError = "ERROR: 3DS failed."
        static let sdkInitError = "ERROR: Failed to initialize Checkout SDK"
    }

    let flutterVc: FlutterViewController
    let paymentChannel: FlutterMethodChannel

    var presentedVC: UIViewController?
    /// Stored so [cancelAddCard] (fired by the VC's Cancel button) can unblock the Dart await.
    var addCardResultHandler: FlutterResult?

    /// Populated by Flow SDK callbacks during add-card, read by `handleSubmit`.
    /// Writes (`onSubmit`, `onTokenized`) and the read (`handleSubmit`) all hop to
    /// the main queue via `DispatchQueue.main.async`; main-queue FIFO then
    /// guarantees the writes land before `handleSubmit` reads.
    var tokenType: String = ""
    var tokenScheme: String = ""

    init(flutterVc: FlutterViewController) {
        self.flutterVc = flutterVc
        self.paymentChannel = FlutterMethodChannel(name: Constants.channelName,
                                                   binaryMessenger: flutterVc.binaryMessenger)
        super.init()

        paymentChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch(call.method) {
            case Constants.addPaymentCardMethod:
                self.addCreditCard(resultHandler: result, arguments: call.arguments)
            case Constants.performThreeDSMethod:
                self.performThreeDS(resultHandler: result, arguments: call.arguments)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }

    // MARK: - Add Credit Card (Flow SDK)

    private func addCreditCard(resultHandler: @escaping FlutterResult, arguments: Any?) {
        // Store the handler so every exit path (success, error, cancel) can complete it
        // exactly once. `finishAddCard` below is the only place we call it from now on.
        self.addCardResultHandler = resultHandler

        // Reset per-session state captured by the Flow SDK callbacks. Called via
        // MethodChannel from Flutter, which already runs on main.
        self.tokenType = ""
        self.tokenScheme = ""

        guard let customerDetails = arguments as? Dictionary<String, String> else {
            finishAddCard(String(Constants.badArgumentsError))
            return
        }

        guard let apiKey = customerDetails["apiKey"] else {
            finishAddCard(String(Constants.apiKeyError))
            return
        }

        guard let paymentSessionId = customerDetails["paymentSessionId"],
              let paymentSessionSecret = customerDetails["paymentSessionSecret"] else {
            finishAddCard(String(Constants.errorPrefix + "Payment session data not provided"))
            return
        }

        let isProduction = customerDetails["environment"] != "staging"
        let environment: CheckoutComponents.Environment = isProduction ? .production : .sandbox

        let applePayMerchantId = customerDetails["applePayMerchantId"]

        // Parse brand color for styling
        var actionColor: Color?
        if let redStr = customerDetails["primaryColorRed"],
           let greenStr = customerDetails["primaryColorGreen"],
           let blueStr = customerDetails["primaryColorBlue"],
           let red = Double(redStr),
           let green = Double(greenStr),
           let blue = Double(blueStr) {
            actionColor = Color(
                red: red / 255.0,
                green: green / 255.0,
                blue: blue / 255.0
            )
        }

        // Localised pay-button label + the app's active language. We set the SDK locale
        // to match the app so the Flow UI is localised consistently, then override the
        // button label (default "Pay") for that same locale.
        let payButtonLabel = customerDetails["payButtonLabel"]
        let sdkLocale: String = {
            switch customerDetails["localeCode"] {
            case "ar": return "ar"
            case "da": return "da_DK"
            case "de": return "de_DE"
            case "el": return "el"
            case "es": return "es_ES"
            case "fi": return "fi_FI"
            case "fil": return "fil_PH"
            case "fr": return "fr_FR"
            case "hi": return "hi_IN"
            case "id": return "id_ID"
            case "it": return "it_IT"
            case "ja": return "ja_JP"
            case "ms": return "ms_MY"
            case "nb": return "nb_NO"
            case "nl": return "nl_NL"
            case "pt": return "pt_PT"
            case "sv": return "sv_SE"
            case "th": return "th_TH"
            case "vi": return "vi_VN"
            case "zh": return "zh_CN"
            default: return "en_GB"
            }
        }()

        Task { @MainActor in
            do {
                // Build appearance with brand color
                var designTokens = CheckoutComponents.DesignTokens()
                if let actionColor = actionColor {
                    designTokens = CheckoutComponents.DesignTokens(
                        colorTokensMain: CheckoutComponents.ColorTokens(action: actionColor)
                    )
                }

                // Flow callbacks:
                // onSubmit  — fires for every method with describable.name ("Card" / "Apple Pay" / "Google Pay"); stores type on self.
                // onTokenized — card-only (SDK's TokenType enum has no wallet cases); stores scheme on self.
                // handleSubmit — forwards sessionData + type + scheme to Dart.
                // onSuccess — notifies Dart; dismisses the SDK UI.
                let callbacks = CheckoutComponents.Callbacks(
                    onSubmit: { [weak self] describable in
                        // Normalise "Apple Pay" → "applepay", "Card" → "card".
                        let name = describable.name.lowercased().replacingOccurrences(of: " ", with: "")
                        NSLog("[AddCard] onSubmit: describable.name=\(describable.name) → type=\(name)")
                        DispatchQueue.main.async { self?.tokenType = name }
                    },
                    onTokenized: { [weak self] tokenizationResult in
                        // preferredScheme is only set when the user picks a scheme on a
                        // co-badged card; the detected scheme lives in data.scheme.
                        let scheme = tokenizationResult.preferredScheme ?? tokenizationResult.data.scheme ?? ""
                        NSLog("[AddCard] onTokenized: scheme=\(scheme)")
                        DispatchQueue.main.async { self?.tokenScheme = scheme }
                        return .accepted
                    },
                    handleSubmit: { [weak self] sessionData in
                        NSLog("[AddCard] handleSubmit: sessionData.length=\(sessionData.count)")
                        guard let self = self else { return .failure }
                        let (type, scheme) = await withCheckedContinuation { (cont: CheckedContinuation<(String, String), Never>) in
                            DispatchQueue.main.async {
                                cont.resume(returning: (self.tokenType, self.tokenScheme))
                            }
                        }
                        return await self.authorizeTokenizationViaDart(
                            sessionData: sessionData,
                            type: type,
                            scheme: scheme,
                            sessionId: paymentSessionId
                        )
                    },
                    onSuccess: { [weak self] _, paymentId in
                        NSLog("[AddCard] onSuccess: paymentId=\(paymentId)")
                        // Single "we're done" signal for every path (card, card+3DS, Apple Pay):
                        // notify Dart, then dismiss the host.
                        DispatchQueue.main.async {
                            self?.finishAddCard("SUCCESS:\(paymentId)")
                            self?.presentedVC?.dismiss(animated: true)
                            self?.presentedVC = nil
                        }
                    },
                    onError: { [weak self] error in
                        NSLog("[AddCard] onError: \(error)")
                        // Cancelling the Apple Pay sheet surfaces here as paymentCancelled.
                        // The Flow SDK leaves its card form presented, so swallow it: finishing
                        // the Dart call would flash an error behind the still-open form and tear
                        // down the channel handler the form still needs. The nav-bar Cancel button
                        // (or completing the card) stays the real exit. Matches Android.
                        if case .paymentCancelled = error.errorCode {
                            return
                        }
                        DispatchQueue.main.async {
                            self?.finishAddCard(String(Constants.errorPrefix + "\(error)"))
                        }
                    }
                )

                // Initialize with PaymentSession from backend
                let paymentSession = PaymentSession(
                    id: paymentSessionId,
                    paymentSessionSecret: paymentSessionSecret
                )

                var translations: [String: [CheckoutComponents.TranslationKey: String]] = [:]
                if let payButtonLabel = payButtonLabel {
                    translations[sdkLocale] = [.payButtonPay: payButtonLabel]
                }

                let configuration = try await CheckoutComponents.Configuration(
                    paymentSession: paymentSession,
                    publicKey: apiKey,
                    environment: environment,
                    appearance: designTokens,
                    locale: sdkLocale,
                    translations: translations,
                    callbacks: callbacks
                )

                let checkoutComponents = CheckoutComponents(configuration: configuration)

                // Flow UI — renders whatever methods the session enables (card always,
                // Apple Pay when merchant id + session include it).
                var flowOptions: Set<CheckoutComponents.PaymentMethod> = [
                    .card(
                        showPayButton: true,
                        cardConfiguration: .init(
                            displayCardHolderName: .top,
                            acceptedCardSchemes: []
                        ),
                        addressConfiguration: nil,
                        rememberMeConfiguration: nil
                    )
                ]
                if let merchantId = applePayMerchantId, !merchantId.isEmpty {
                    flowOptions.insert(.applePay(merchantIdentifier: merchantId))
                }

                let component = try checkoutComponents.create(.flow(options: flowOptions))

                guard let renderable = component as? any CheckoutComponents.Renderable,
                      renderable.isAvailable else {
                    finishAddCard(String(Constants.errorPrefix + "Card component not available"))
                    return
                }

                let swiftUIView = renderable.render()
                let hostingController = UIHostingController(rootView: swiftUIView)
                // Wrap in a UINavigationController so we can show a Cancel button in the nav bar.
                let navController = UINavigationController(rootViewController: hostingController)

                hostingController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .cancel,
                    target: self,
                    action: #selector(self.cancelAddCard)
                )

                // Still attach the presentation delegate so swipe-to-dismiss also
                // routes through our cancel path.
                navController.presentationController?.delegate = self
                self.presentedVC = navController
                self.flutterVc.present(navController, animated: true)

            } catch {
                finishAddCard(String(Constants.sdkInitError + ": \(error)"))
            }
        }
    }

    /// Wired to the nav bar's Cancel button.
    @objc private func cancelAddCard() {
        presentedVC?.dismiss(animated: true)
        presentedVC = nil
        finishAddCard(String(Constants.cancelledResponse))
    }

    /// Completes the Dart-side `addPaymentCard` call exactly once and clears the stored handler.
    private func finishAddCard(_ result: String) {
        guard let handler = addCardResultHandler else { return }
        addCardResultHandler = nil
        handler(result)
    }

    /// Asks Dart to call the BE's authorize-tokenization endpoint and parses the response
    /// into a PaymentSessionSubmissionResult the SDK can use to drive 3DS internally.
    private func authorizeTokenizationViaDart(
        sessionData: String,
        type: String,
        scheme: String,
        sessionId: String
    ) async -> CheckoutComponents.APICallResult {
        let response: Any? = await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.paymentChannel.invokeMethod(
                    "authorizeTokenization",
                    arguments: ["sessionData": sessionData, "type": type, "scheme": scheme]
                ) { result in
                    continuation.resume(returning: result)
                }
            }
        }

        guard let dict = response as? [String: Any],
              let actionDataString = dict["actionData"] as? String,
              let actionDataJson = actionDataString.data(using: .utf8),
              let actionData = try? JSONSerialization.jsonObject(with: actionDataJson) as? [String: Any] else {
            NSLog("[AddCard] authorizeTokenizationViaDart: parse failed. response=\(String(describing: response))")
            return .failure
        }
        NSLog("[AddCard] authorizeTokenizationViaDart: got actionData=\(actionData)")

        let id = actionData["id"] as? String ?? sessionId
        let status = actionData["status"] as? String ?? ""
        let type = actionData["type"] as? String ?? "card"

        var action: CheckoutComponents.Action? = nil
        if let innerAction = actionData["action"] as? [String: Any],
           let actionType = innerAction["type"] as? String,
           let actionUrl = innerAction["url"] as? String {
            action = CheckoutComponents.Action(type: actionType, url: actionUrl)
        }

        return .success(CheckoutComponents.PaymentSessionSubmissionResult(
            id: id,
            status: status,
            type: type,
            action: action
        ))
    }

    // MARK: - 3DS Authentication (Custom WKWebView)

    var threeDsFlutterResult: FlutterResult?

    func performThreeDS(resultHandler: @escaping FlutterResult, arguments: Any?) {
        guard let argumentsDict = arguments as? Dictionary<String, String> else {
            resultHandler(String(Constants.badThreeDSArgumentsError))
            return
        }

        guard let urlStr = argumentsDict["threeDsUrl"] else {
            resultHandler(String(Constants.threeDSUrlError))
            return
        }

        guard let url = URL(string: urlStr) else {
            resultHandler(String(Constants.threeDSUrlInvalidError))
            return
        }

        self.threeDsFlutterResult = resultHandler

        let threeDsVC = ThreeDSViewController(
            challengeURL: url,
            successURL: URL(string: "https://success.payment.complete/")!,
            failureURL: URL(string: "https://failure.payment.complete/")!
        )
        threeDsVC.delegate = self

        let navController = UINavigationController(rootViewController: threeDsVC)
        self.presentedVC = navController
        flutterVc.present(navController, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension PaymentProcessor: UIAdaptivePresentationControllerDelegate {
    /// Fires when the user swipe-dismisses the add-card sheet without completing tokenisation.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presentedVC = nil
        finishAddCard(String(Constants.cancelledResponse))
    }
}

// MARK: - ThreeDSViewControllerDelegate

protocol ThreeDSViewControllerDelegate: AnyObject {
    func threeDSDidSucceed(token: String?)
    func threeDSDidFail()
}

extension PaymentProcessor: ThreeDSViewControllerDelegate {
    func threeDSDidSucceed(token: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.presentedVC?.dismiss(animated: true)
            self?.presentedVC = nil
        }

        // Return token if available, otherwise return SUCCESS to indicate
        // 3DS completed (e.g. payment session flow doesn't return a token)
        threeDsFlutterResult?(String(token ?? "SUCCESS"))
        threeDsFlutterResult = nil
    }

    func threeDSDidFail() {
        DispatchQueue.main.async { [weak self] in
            self?.presentedVC?.dismiss(animated: true)
            self?.presentedVC = nil
        }

        threeDsFlutterResult?(String(Constants.threeDSFailedError))
        threeDsFlutterResult = nil
    }
}

// MARK: - ThreeDSViewController (Custom WKWebView-based 3DS handler)

class ThreeDSViewController: UIViewController, WKNavigationDelegate {

    private let challengeURL: URL
    private let successURL: URL
    private let failureURL: URL
    private var webView: WKWebView!

    weak var delegate: ThreeDSViewControllerDelegate?

    init(challengeURL: URL, successURL: URL, failureURL: URL) {
        self.challengeURL = challengeURL
        self.successURL = successURL
        self.failureURL = failureURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Verification"

        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)

        webView.load(URLRequest(url: challengeURL))
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Check if we're being redirected to the success URL
        if url.absoluteString.hasPrefix(successURL.absoluteString) {
            decisionHandler(.cancel)
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let token = components?.queryItems?.first(where: { $0.name == "cko-payment-token" })?.value
            delegate?.threeDSDidSucceed(token: token)
            return
        }

        // Check if we're being redirected to the failure URL
        if url.absoluteString.hasPrefix(failureURL.absoluteString) {
            decisionHandler(.cancel)
            delegate?.threeDSDidFail()
            return
        }

        decisionHandler(.allow)
    }
}
