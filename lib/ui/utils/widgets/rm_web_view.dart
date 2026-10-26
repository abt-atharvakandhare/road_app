import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RMWebView extends StatelessWidget {
  RMWebView({super.key, required this.initialUri, required this.title}) {
    controller.loadRequest(initialUri);
  }

  static void pushAsModal(BuildContext context, Uri initialUri, String title) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((routeContext) {
              return RMWebView(initialUri: initialUri, title: title);
            }),
            fullscreenDialog: true));
  }

  final Uri initialUri;
  final String title;

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000));
  // ..setNavigationDelegate(
  //   NavigationDelegate(
  //     onWebResourceError: (WebResourceError error) {},
  //     onNavigationRequest: (NavigationRequest request) {
  //       log('NavigationRequest: ${request.url}');
  //       if (request.url.startsWith('https://www.youtube.com/')) {
  //         return NavigationDecision.prevent;
  //       }
  //       return NavigationDecision.navigate;
  //     },
  //   ),
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(title, style: const TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: WebViewWidget(controller: controller),
    );
  }
}
