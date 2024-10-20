import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController webViewController;
  bool isLoading = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onUrlChange: (UrlChange change) {
            counter++;
            if (counter == 2) {
              setState(() {
              isLoading = true;
            });
            }
            debugPrint('Url changed: ${change.url}');
            if (change.url!.contains('success=true')) {
              Future.delayed(const Duration(seconds: 2), () {
                if(mounted) Navigator.pop(context);
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment Successful')),
              );
            } else if (change.url!.contains('success=false')) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment Failed')),
              );
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));

    webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
    canPop:  !isLoading,
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isLoading,
        title: const Text('Balance recharge'),
      ),
      body: WebViewWidget(
        controller: webViewController,
      ),
    ),
  );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
