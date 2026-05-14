import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
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

  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (UrlChange change) async {
            final url = change.url ?? '';
            debugPrint('URL changed to $url');
            if (url.contains('success')) {
              await ref
                  .read(
                    paymentOrchestratorViewModelProvider(
                      widget.agreementId,
                    ).notifier,
                  )
                  .verifyTransaction();
            } else if (url.contains('failed')) {
              await ref
                  .read(
                    paymentOrchestratorViewModelProvider(
                      widget.agreementId,
                    ).notifier,
                  )
                  .verifyTransaction();
            } else if (url.contains('cancelled')) {
              await ref
                  .read(
                    paymentOrchestratorViewModelProvider(
                      widget.agreementId,
                    ).notifier,
                  )
                  .verifyTransaction();
            }
          },
          onProgress: (int progress) {
            // Update loading bar.
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() {
              loading = false;
            });
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Http error: ${error.response}');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (loading) LinearProgressIndicator(),
        ],
      ),
    );
  }
}
