import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:cleer/domain/models/enums/payment_method_type.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutterwave_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Bank>> getBanks(Ref ref, CountryCode countryCode) async {
  final repository = ref.watch(flutterwaveRepositoryProvider);

  final result = await repository.getBanks(countryCode);
  return result.fold((banks) => banks, (failure) => throw failure);
}

@Riverpod(keepAlive: true)
Future<List<PaymentMethod>> flutterwaveSavedPaymentMethods(Ref ref) async {
  final repository = ref.watch(flutterwaveRepositoryProvider);
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return [];

  final ids = user.flutterwavePaymentMethodIds;
  if (ids.isEmpty) return [];

  final results = await Future.wait(
    ids.map((id) => repository.getPaymentMethod(id)),
  );

  return results
      .where((r) => r.isSuccess())
      .map((r) => r.getOrThrow())
      .toList();
}

@riverpod
bool hasOpayMethod(Ref ref) {
  final savedMethods =
      ref.watch(flutterwaveSavedPaymentMethodsProvider).value ?? [];

  return savedMethods.any((m) => m.type == PaymentMethodType.opay);
}

@riverpod
PaymentMethod? opayMethod(Ref ref) {
  return ref
      .watch(flutterwaveSavedPaymentMethodsProvider)
      .value
      ?.firstWhereOrNull((m) => m.type == PaymentMethodType.opay);
}

@riverpod
bool hasBankUSSDMethod(Ref ref, String bankCode) {
  final savedMethods =
      ref.watch(flutterwaveSavedPaymentMethodsProvider).value ?? [];

  return savedMethods.any(
    (m) =>
        m.type == PaymentMethodType.ussd &&
        m.ussdDetails?.accountBankCode == bankCode,
  );
}

@riverpod
PaymentMethod? bankUSSDMethod(Ref ref, String bankCode) {
  return ref
      .watch(flutterwaveSavedPaymentMethodsProvider)
      .value
      ?.firstWhereOrNull(
        (m) =>
            m.type == PaymentMethodType.ussd &&
            m.ussdDetails?.accountBankCode == bankCode,
      );
}

@riverpod
bool hasCardMethod(Ref ref) {
  final savedMethods =
      ref.watch(flutterwaveSavedPaymentMethodsProvider).value ?? [];

  return savedMethods.any((m) => m.type == PaymentMethodType.card);
}

@riverpod
List<PaymentMethod>? cardMethods(Ref ref) {
  return ref
      .watch(flutterwaveSavedPaymentMethodsProvider)
      .value
      ?.where((m) => m.type == PaymentMethodType.card)
      .toList();
}
