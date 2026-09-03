import 'dart:async';
import 'dart:convert';

import 'package:cleer_ui/cleer_ui.dart';
import 'package:gap/gap.dart';
import 'package:universal_html/html.dart' as html;
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthorizingWebView extends ConsumerStatefulWidget {
  const AuthorizingWebView({
    super.key,
    required this.agreementId,
    required this.url,
  });
  final String agreementId;
  final String url;

  @override
  ConsumerState<AuthorizingWebView> createState() => _AuthorizingWebViewState();
}

class _AuthorizingWebViewState extends ConsumerState<AuthorizingWebView> {
  late WebViewController webViewController;
  bool loading = true;
  StreamSubscription? _webMessageSubscription;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _initWebPaymentFlow();
    } else {
      _initMobileWebView();
    }
  }

  void _initWebPaymentFlow() async {
    // Clear any lingering data from previous failed payments
    html.window.localStorage.remove('flutterwave_payment_status');

    // Listen to PostMessage (Standard)
    _webMessageSubscription = html.window.onMessage.listen((event) async {
      try {
        final data = event.data;
        if (data != null && data is Map && data['type'] == 'payment_status') {
          final String status = data['status']?.toString() ?? '';
          debugPrint('Web Payment status via Message: $status');
          await _handleStatus(status);
        }
      } catch (_) {
        /* Ignore JS parsing errors */
      }
    });

    // Listen to LocalStorage (Fallback)
    html.window.onStorage.listen((html.StorageEvent event) async {
      if (event.key == 'flutterwave_payment_status' && event.newValue != null) {
        // Immediately delete the key so it can never be read twice
        html.window.localStorage.remove('flutterwave_payment_status');

        try {
          final decoded = jsonDecode(event.newValue!);
          final String status = decoded['status']?.toString() ?? '';
          debugPrint('Web Payment status via Storage: $status');
          await _handleStatus(status);
        } catch (_) {}
      }
    });

    // Launch the Flutterwave payment gateway using HTML directly
    html.window.open(widget.url, 'FlutterwaveCheckout');
  }

  // Helper method so we don't duplicate logic
  Future<void> _handleStatus(String status) async {
    if (status == 'successful' || status == 'failed' || status == 'cancelled') {
      await _triggerVerification();
    }
  }

  // --- MOBILE LOGIC ---
  void _initMobileWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url;
            debugPrint('Navigation request to: $url');

            // 1. Check if payment completion/redirect URL was reached
            if (url.contains('close_payment.html') ||
                url.contains('success') ||
                url.contains('failed') ||
                url.contains('cancelled')) {
              await _triggerVerification();
              return NavigationDecision.navigate;
            }

            // 2. Silently prevent non-HTTP/HTTPS schemes (e.g. btravel://, opay://) so WebView doesn't crash
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              debugPrint('Silently preventing non-HTTP scheme: $url');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) async {
            final url = change.url ?? '';
            debugPrint('URL changed to $url');
            if (url.contains('close_payment.html') ||
                url.contains('success') ||
                url.contains('failed') ||
                url.contains('cancelled')) {
              await _triggerVerification();
            }
          },
          onPageFinished: (String url) {
            setState(() {
              loading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _triggerVerification() async {
    if (!mounted) return;
    await ref
        .read(paymentOrchestratorViewModelProvider(widget.agreementId).notifier)
        .verifyTransaction();
  }

  @override
  void dispose() {
    _webMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Web Layout UI
    if (kIsWeb) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Gap(Dimens.spacing.sp16),
              Text('Please complete your payment in the opened tab...'),
            ],
          ),
        ),
      );
    }

    // Mobile Layout UI
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
