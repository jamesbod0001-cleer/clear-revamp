import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        tapTargetSize: .shrinkWrap,
        visualDensity: .compact,
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
      ),
      onPressed: () => context.pop(),
      icon: PhosphorIcon(PhosphorIcons.arrowLeft()),
    );
  }
}
