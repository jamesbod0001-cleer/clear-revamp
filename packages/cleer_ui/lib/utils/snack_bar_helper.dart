import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SnackBarHelper {
  static OverlayEntry? _previousEntry;

  static void showNotification(String message) {
    final context = cleerNavigatorKey.currentContext;
    if (context == null) return;
    _showTop(
      message,
      backgroundColor: context.color.info,
      foregroundColor: context.color.infoLight,
      icon: PhosphorIcons.bellRinging(.duotone),
    );
  }

  static void showSuccess(String message) {
    final context = cleerNavigatorKey.currentContext;
    if (context == null) return;
    _showTop(
      message,
      backgroundColor: context.color.success,
      foregroundColor: context.color.successLight,
      icon: PhosphorIcons.checkCircle(.duotone),
    );
  }

  static void showError(String message) {
    final context = cleerNavigatorKey.currentContext;
    if (context == null) return;
    _showTop(
      message,
      backgroundColor: context.color.error,
      foregroundColor: context.color.errorLight,
      icon: PhosphorIcons.xCircle(.duotone),
    );
  }

  static void _showTop(
    String message, {
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
  }) {
    final state = cleerNavigatorKey.currentState;

    if (state == null) return;

    // Remove existing snackBar if one is showing
    _previousEntry?.remove();

    final overlay = cleerNavigatorKey.currentState!.overlay;
    final entry = OverlayEntry(
      builder: (context) => _TopSnackBarWidget(
        message: message,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        icon: icon,
        onDismiss: () {
          _previousEntry?.remove();
          _previousEntry = null;
        },
      ),
    );

    _previousEntry = entry;
    overlay?.insert(entry);
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.message,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isDismissedManually = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_isDismissedManually) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + Dimens.padding.p32,
      left: Dimens.padding.p18,
      right: Dimens.padding.p18,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.up,
          onDismissed: (_) {
            _isDismissedManually = true;
            widget.onDismiss();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.padding.p12,
                vertical: Dimens.padding.p8,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(Dimens.radius.r8),
              ),
              child: Row(
                children: [
                  PhosphorIcon(
                    widget.icon,
                    size: Dimens.size.s16,
                    color: widget.foregroundColor,
                  ),
                  Gap(Dimens.spacing.sp6),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: context.typo.bodyMedium.copyWith(
                        color: widget.foregroundColor,
                      ),
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
