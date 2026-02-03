import 'package:cleer/domain/models/agreement/agreement_enums.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/ui/agreements/create_agreement/models/agreement_type.dart';
import 'package:cleer/ui/agreements/create_agreement/view_model/create_agreement_view_model.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/agreement_numpad_overlay.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/disbursement_type_selector.dart';
import 'package:cleer/ui/agreements/create_agreement/widgets/recipient_identity_tile.dart';
import 'package:cleer/ui/core/localization/generated/app_localizations.dart';
import 'package:cleer/ui/core/themes/dimensions.dart';
import 'package:cleer/ui/core/themes/theme_utils.dart';
import 'package:cleer/ui/core/ui/bottom_sheets/bank_picker_bottom_sheet.dart';
import 'package:cleer/ui/core/ui/buttons/primary_button.dart';
import 'package:cleer/ui/core/ui/custom_text_form_field.dart';
import 'package:cleer/ui/profile/profile/widgets/profile_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AgreementSetupStep extends HookConsumerWidget {
  const AgreementSetupStep({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(createAgreementViewModelProvider(type));
    final viewModel = ref.read(createAgreementViewModelProvider(type).notifier);

    String formattedAmount = state.value?.formData.amount != null && state.value!.formData.amount.isNotEmpty
        ? NumberFormat('#,###.##').format(double.parse(state.value!.formData.amount))
        : '';

    final TextEditingController amountController = useTextEditingController(
      text: formattedAmount,
    );
    final ValueNotifier<Bank?> selectedBank = useState<Bank?>(
      state.value?.formData.recipientBank,
    );
    final bankController = useTextEditingController(
      text: selectedBank.value?.name,
    );
    final TextEditingController accountNumberController =
        useTextEditingController(
          text: state.value?.formData.recipientAccountNumber,
        );
    final ValueNotifier<DisbursementType?> selectedDisbursementType =
        useState<DisbursementType?>(state.value?.formData.disbursementType);

    useEffect(() {
      bankController.text = selectedBank.value?.name ?? '';
      return null;
    }, [selectedBank.value]);

    useEffect(() {
      if (amountController.text == '') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAgreementNumpadOverlay(context, amountController);
        });
      }
      return null;
    }, [amountController]);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.onFormChanged(
            state.value!.formData.copyWith(
              amount: amountController.text.replaceAll(',', ''),
              recipientBank: selectedBank.value,
              recipientAccountNumber: accountNumberController.text,
            ),
          );
        });
        return null;
      },
      [amountController.text, selectedBank.value, accountNumberController.text],
    );

    bool isRecipientDetailsValid =
        selectedBank.value != null && accountNumberController.text.length == 10;

    useEffect(() {
      if (isRecipientDetailsValid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.resolveRecipientDetails();
        });
      }
      return null;
    }, [selectedBank.value, accountNumberController.text]);

    final formData = state.value?.formData;
    final resolution = state.value?.recipientResolution;

    final bool isFormComplete =
        (formData?.amount.isNotEmpty ?? false) &&
        (formData?.recipientAccountNumber.length == 10) &&
        (formData?.recipientBank != null) &&
        (formData?.disbursementType != null) &&
        (resolution != null);

    return Form(
      onChanged: () {
        viewModel.onFormChanged(
          state.value!.formData.copyWith(
            amount: amountController.text.replaceAll(',', ''),
            recipientBank: selectedBank.value,
            recipientAccountNumber: accountNumberController.text,
          ),
        );
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: Dimens.mobile.edgeInsetsScreenHorizontal,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Gap(Dimens.spacing.sp12),
                CustomTextFormField(
                  controller: amountController,
                  labelText: l10n.amount,
                  readOnly: true,
                  onTap: () =>
                      _showAgreementNumpadOverlay(context, amountController),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: Dimens.padding.p8),
                    child: Text(
                      l10n.nairaSign,
                      style: context.typo.bodyLarge.copyWith(
                        color: context.color.grey600,
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        _showAgreementNumpadOverlay(context, amountController),
                    icon: PhosphorIcon(
                      PhosphorIcons.numpad(),
                      color: context.color.blue700,
                    ),
                  ),
                ),
                Gap(Dimens.spacing.sp40),

                ProfileSectionHeader(title: l10n.recipientDetails),
                CustomTextFormField(
                  controller: bankController,
                  labelText: l10n.selectBank,
                  readOnly: true,
                  onTap: () =>
                      _showBankPickerBottomSheet(context, selectedBank),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        _showBankPickerBottomSheet(context, selectedBank),
                    icon: PhosphorIcon(
                      PhosphorIcons.caretDown(),
                      color: context.color.blue700,
                    ),
                  ),
                ),
                Gap(Dimens.spacing.sp20),
                CustomTextFormField(
                  controller: accountNumberController,
                  labelText: l10n.accountNumber,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired('account number');
                    }
                    if (value.length != 10) {
                      return l10n.enterAValid10DigitsAccountNumber;
                    }
                    return null;
                  },
                ),
                RecipientIdentityTile(type: type),
                Gap(Dimens.spacing.sp40),

                ProfileSectionHeader(title: l10n.howWillThePaymentBeReleased),
                DisbursementTypeSelector(
                  selectedType: selectedDisbursementType.value,
                  onChanged: (value) {
                    selectedDisbursementType.value = value;
                    viewModel.onFormChanged(
                      state.value!.formData.copyWith(disbursementType: value),
                    );
                  },
                ),
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: Dimens.mobile.edgeInsetsScreenHorizontal.copyWith(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  Gap(Dimens.spacing.sp30),
                  PrimaryButton(
                    onPressed: isFormComplete
                        ? () => viewModel.moveToNextStep()
                        : null,
                    child: Text(l10n.next),
                  ),
                  Gap(Dimens.spacing.sp20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAgreementNumpadOverlay(
    BuildContext context,
    TextEditingController amountController,
  ) => showDialog(
    context: context,
    useRootNavigator: true,
    fullscreenDialog: true,
    useSafeArea: false,
    animationStyle: .new(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 200),
    ),
    builder: (context) => AgreementNumpadOverlay(
      initialAmount: amountController.text.replaceAll(',', ''),
      type: type,
      onSubmitted: (value) {
        amountController.text = NumberFormat(
          '#,###.##',
        ).format(double.parse(value));
      },
    ),
  );

  void _showBankPickerBottomSheet(
    BuildContext context,
    ValueNotifier<Bank?> selectedBank,
  ) => BankPickerBottomSheet.show(context).then((bank) {
    if (bank != null) {
      selectedBank.value = bank;
    }
  });
}
