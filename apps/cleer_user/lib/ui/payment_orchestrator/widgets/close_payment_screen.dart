import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClosePaymentScreen extends ConsumerStatefulWidget {
  const ClosePaymentScreen({super.key, this.response});
  final String? response;

  @override
  ConsumerState<ClosePaymentScreen> createState() => _ClosePaymentScreenState();
}

class _ClosePaymentScreenState extends ConsumerState<ClosePaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
