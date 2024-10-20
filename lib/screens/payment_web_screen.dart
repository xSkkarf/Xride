import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:xride/cubit/payment/payment_cubit.dart';

class PaymentWebView extends StatefulWidget {
  final PaymentWebArgs paymentArgs;

  const PaymentWebView({
    super.key,
    required this.paymentArgs,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController webViewController;
  bool isLoading = false;
  int counter = 0;
  bool isSuccess = false;

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
              isSuccess = true;
              Future.delayed(const Duration(seconds: 4), () {
                if(mounted) Navigator.pop(context);
              });

            } else if (change.url!.contains('success=false')) {
              if(mounted) Navigator.pop(context);
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
      ..loadRequest(Uri.parse(widget.paymentArgs.paymentUrl));

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
    widget.paymentArgs.paymentStatusCallBack(isSuccess ? 'success' : 'fail');
  }
}
