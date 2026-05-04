import 'package:cleer/config/assets.gen.dart';
import 'package:cleer/domain/models/enums/card_network.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/providers/flutterwave/flutterwave_provider.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/ui/payment_orchestrator/view_model/payment_orchestrator_view_model.dart';
import 'package:cleer/ui/payment_orchestrator/widgets/step_header.dart';
import 'package:cleer/ui/core/utils/formatters/card_expiry_formatter.dart';
import 'package:cleer/ui/core/utils/formatters/card_number_formatter.dart';
import 'package:cleer/utils/validators/card_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EnterCardDetailsStep extends HookConsumerWidget {
  const EnterCardDetailsStep({super.key, required this.agreementId});
  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(paymentOrchestratorViewModelProvider(agreementId));
    final viewModel = ref.read(
      paymentOrchestratorViewModelProvider(agreementId).notifier,
    );
    final agreement = state.value!.agreement;

    TextEditingController cardNumberController = useTextEditingController();
    TextEditingController cardExpiryController = useTextEditingController();
    TextEditingController cardCVVController = useTextEditingController();

    final network = useState<CardNetwork>(CardNetwork.unknown);
    final rememberCard = useState<bool>(false);

    final FocusNode expiryFocusNode = useFocusNode();

    useEffect(() {
      void listener() {
        final cleanValue = cardNumberController.text.replaceAll(' ', '');
        network.value = CardNetwork.fromNumber(cleanValue);

        final expectedLength = (network.value == CardNetwork.verve) ? 19 : 16;

        if (cleanValue.length == expectedLength) {
          expiryFocusNode.requestFocus();
        }
      }

      cardNumberController.addListener(listener);

      return () => cardNumberController.removeListener(listener);
    }, [cardNumberController]);

    final removeCardCommand = viewModel.removeCard;
    useEffect(() {
      void listener() {
        if (removeCardCommand.errors.value != null) {
          debugPrint("Command Error: ${removeCardCommand.errors.value?.error}");
        }
      }

      removeCardCommand.errors.addListener(listener);
      return () => removeCardCommand.errors.removeListener(listener);
    }, [removeCardCommand]);

    bool usingSavedCard = ref.watch(hasCardMethodProvider);
    ValueNotifier<PaymentMethod?> savedCard = useState(null);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // If didPop is true, the screen is already closing.
        if (didPop) return;
        viewModel.changePaymentMethod(); // Going back to change payment method
      },
      child: Column(
        children: [
          StepHeader(title: l10n.enterYourCardDetailsToPay),
          Gap(Dimens.spacing.sp40),
          Visibility(
            visible: usingSavedCard,
            replacement: Column(
              children: [
                CustomTextFormField(
                  controller: cardNumberController,
                  labelText: l10n.cardNumber,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                    CardNumberFormatter(),
                  ],
                  validator: (number) => validateCardNumber(number, l10n),
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(Dimens.padding.p8),
                    child: _getCardIcon(network.value, context),
                  ),
                ),
                Gap(Dimens.spacing.sp20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: cardExpiryController,
                        focusNode: expiryFocusNode,
                        labelText: l10n.cardExpiry,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                          CardExpiryFormatter(),
                        ],
                        validator: (expiry) => validateExpiryDate(expiry, l10n),
                      ),
                    ),
                    Gap(Dimens.spacing.sp20),
                    Expanded(
                      child: CustomTextFormField(
                        controller: cardCVVController,
                        labelText: l10n.cvv,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (cvv) =>
                            validateCVV(cvv, network.value, l10n),
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp20),
                Row(
                  children: [
                    CustomCheckbox(
                      value: rememberCard.value,
                      onChanged: (value) {
                        rememberCard.value = value!;
                      },
                    ),
                    Gap(Dimens.spacing.sp5),
                    Text(
                      l10n.rememberThisCardForNextTime,
                      style: context.typo.bodyMedium.copyWith(
                        color: context.color.grey800,
                      ),
                    ),
                  ],
                ),
                Gap(Dimens.spacing.sp20),
              ],
            ),
            child: ValueListenableBuilder(
              valueListenable: viewModel.removeCard.isRunning,
              builder: (BuildContext context, bool isRunning, _) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        Column(
                          children: List.generate(
                            ref.watch(cardMethodsProvider)?.length ?? 0,
                            (int index) {
                              final method = ref
                                  .watch(cardMethodsProvider)!
                                  .elementAt(index);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                savedCard.value = method;
                              });
                              final cardDetails = method.cardDetails!;
                              return Container(
                                decoration: BoxDecoration(
                                  color: context.color.grayComponent,
                                  border: .all(color: context.color.outline),
                                  borderRadius: .circular(Dimens.radius.r8),
                                ),
                                padding: .all(Dimens.padding.p8),
                                child: Row(
                                  children: [
                                    _getCardIcon(
                                      cardDetails.network,
                                      context,
                                      width: Dimens.size.s40,
                                    ),
                                    Gap(Dimens.spacing.sp8),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: .min,
                                        crossAxisAlignment: .start,
                                        children: [
                                          Text(
                                            cardDetails.maskedNumber,
                                            style: context.typo.titleLarge
                                                .copyWith(
                                                  color: context.color.grey800,
                                                ),
                                          ),
                                          Gap(Dimens.spacing.sp4),
                                          Text(
                                            cardDetails.cardHolderName ?? '',
                                            style: context.typo.bodyMedium
                                                .copyWith(
                                                  fontWeight:
                                                      AppFontWeights.regular,
                                                  color: context.color.grey600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Gap(Dimens.spacing.sp14),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: context.color.error,
                                        textStyle: context.typo.bodyLink
                                            .copyWith(
                                              decorationThickness: 2,
                                              decorationColor:
                                                  context.color.error,
                                            ),
                                        minimumSize: .zero,
                                        padding: .symmetric(
                                          vertical: Dimens.padding.p4,
                                        ),
                                      ),
                                      onPressed: () {
                                        viewModel.removeCard.clearErrors();
                                        viewModel.removeCard.runAsync(
                                          method.id,
                                        );
                                      },
                                      child: Text(l10n.remove),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Gap(Dimens.spacing.sp100),
                        Text(
                          l10n.usingSavedCard,
                          style: context.typo.labelSmall,
                        ),
                        Gap(Dimens.spacing.sp40),
                      ],
                    ),
                    if (isRunning ||
                        ref
                            .watch(flutterwaveSavedPaymentMethodsProvider)
                            .isLoading)
                      Positioned.fill(
                        child: Material(
                          color: context.color.background,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          PrimaryButton(
            onPressed: () {
              if (usingSavedCard) {
                viewModel.securePaymentWithSavedCard(savedCard.value!);
              } else {
                viewModel.securePaymentWithNewCard(
                  cardNumberController.text.replaceAll(' ', ''),
                  cardExpiryController.text.split('/').first,
                  cardExpiryController.text.split('/').last,
                  cardCVVController.text,
                  saveCard: rememberCard.value,
                );
              }
            },
            child: Text(
              l10n.secureAmount(
                "${l10n.ngn} ${NumberFormat('#,###.##').format(agreement.amount)}",
              ),
            ),
          ),
          Gap(Dimens.spacing.sp48),
        ],
      ),
    );
  }

  Widget _getCardIcon(
    CardNetwork network,
    BuildContext context, {
    double? width,
  }) {
    double size = width ?? Dimens.size.s32;
    switch (network) {
      case CardNetwork.visa:
        return Assets.icons.visa.svg(width: size);
      case CardNetwork.mastercard:
        return Assets.icons.mastercard.svg(width: size);
      case CardNetwork.verve:
        return Assets.icons.verve.svg(width: size);
      case CardNetwork.americanExpress:
        return Assets.icons.americanExpress.svg(width: size);
      case CardNetwork.discover:
        return Assets.icons.discover.svg(width: size);
      case CardNetwork.unknown:
      default:
        return PhosphorIcon(
          PhosphorIcons.creditCard(),
          size: size,
          color: context.color.blue700,
        );
    }
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: value
            ? PhosphorIcon(
                PhosphorIcons.checkSquare(),
                size: Dimens.size.s20,
                color: context.color.blue700,
              )
            : PhosphorIcon(
                PhosphorIcons.square(),
                size: Dimens.size.s20,
                color: context.color.blue700,
              ),
      ),
    );
  }
}
