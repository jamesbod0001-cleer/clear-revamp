import 'package:cleer_ui/generated/assets.gen.dart';
import 'package:cleer_ui/themes/dimensions.dart';
import 'package:cleer_ui/themes/theme.dart';
import 'package:cleer_ui/themes/theme_utils.dart';
import 'package:cleer_ui/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SnackBarHelper {
  static OverlayEntry? _previousEntry;

  static void showNotification({
    required String title,
    String? formattedAmount,
    String? description,
    String? activityType,
  }) {
    final context = cleerNavigatorKey.currentContext;
    if (context == null) return;

    Color stripeColor;
    Color backgroundColor;
    Color iconBackgroundColor;
    Widget icon;

    final type = activityType?.toUpperCase() ?? '';

    switch (type) {
      case 'PAYMENT':
        stripeColor = context.color.green800;
        backgroundColor = context.color.green000;
        iconBackgroundColor = context.color.green150;
        icon = PhosphorIcon(
          PhosphorIcons.moneyWavy(PhosphorIconsStyle.duotone),
          color: context.color.green800,
          size: Dimens.size.s16,
        );
      case 'AGREEMENT':
        stripeColor = context.color.blue800;
        backgroundColor = context.color.blue100;
        iconBackgroundColor = context.color.infoLight;
        icon = Assets.images.handshake.image(height: Dimens.size.s12);

      default:
        stripeColor = context.color.blue800;
        backgroundColor = context.color.blue100;
        iconBackgroundColor = context.color.infoLight;
        icon = PhosphorIcon(
          PhosphorIcons.bellRinging(PhosphorIconsStyle.duotone),
          color: context.color.blue800,
          size: Dimens.size.s16,
        );
    }

    _showSide(
      title: title,
      formattedAmount: formattedAmount,
      description: description,
      stripeColor: stripeColor,
      backgroundColor: backgroundColor,
      iconBackgroundColor: iconBackgroundColor,
      icon: icon,
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

  static void _showSide({
    required String title,
    String? formattedAmount,
    String? description,
    required Color stripeColor,
    required Color backgroundColor,
    required Color iconBackgroundColor,
    required Widget icon,
  }) {
    final state = cleerNavigatorKey.currentState;
    if (state == null) return;

    _previousEntry?.remove();

    final overlay = cleerNavigatorKey.currentState!.overlay;
    final entry = OverlayEntry(
      builder: (context) => _SideNotificationWidget(
        title: title,
        formattedAmount: formattedAmount,
        description: description,
        stripeColor: stripeColor,
        iconBackgroundColor: iconBackgroundColor,
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

class _SideNotificationWidget extends StatefulWidget {
  final String title;
  final String? formattedAmount;
  final String? description;
  final Color stripeColor;
  final Color backgroundColor;
  final Widget icon;
  final Color iconBackgroundColor;
  final VoidCallback onDismiss;

  const _SideNotificationWidget({
    required this.title,
    this.formattedAmount,
    this.description,
    required this.stripeColor,
    required this.backgroundColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.onDismiss,
  });

  @override
  State<_SideNotificationWidget> createState() =>
      _SideNotificationWidgetState();
}

class _SideNotificationWidgetState extends State<_SideNotificationWidget>
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

    // Animates horizontally from the right
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

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
    final hasFooterData =
        widget.formattedAmount != null || widget.description != null;

    return Positioned(
      top: MediaQuery.of(context).padding.top + Dimens.padding.p16,
      left: Dimens.padding.p18,
      right: Dimens.padding.p18,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal, // Swipe left/right to dismiss
          onDismissed: (_) {
            _isDismissedManually = true;
            widget.onDismiss();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              clipBehavior: Clip.hardEdge,
              padding: .all(Dimens.padding.p8),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(Dimens.radius.r8),
                ),
                border: Border(
                  left: BorderSide(
                    color: widget.stripeColor,
                    width: Dimens.size.s3,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D0C0C0D),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: Dimens.size.s32,
                    width: Dimens.size.s32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.iconBackgroundColor,
                    ),
                    child: Center(child: widget.icon),
                  ),
                  Gap(Dimens.spacing.sp10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: context.typo.bodyMedium.copyWith(
                            color: context.color.grey800,
                            fontWeight: AppFontWeights.regular,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasFooterData) ...[
                          Gap(Dimens.spacing.sp2),
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: context.typo.bodyMedium.copyWith(
                                color: context.color.grey600,
                              ),
                              children: [
                                if (widget.formattedAmount != null)
                                  TextSpan(
                                    text: widget.formattedAmount,
                                    style: TextStyle(
                                      color: context.color.grey1000,
                                    ),
                                  ),
                                if (widget.formattedAmount != null &&
                                    widget.description != null)
                                  const TextSpan(text: ' · '),
                                if (widget.description != null)
                                  TextSpan(text: widget.description),
                              ],
                            ),
                          ),
                        ],
                      ],
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
