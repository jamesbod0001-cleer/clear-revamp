import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:cleer/domain/models/payment_method/payment_method.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
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
  final user = ref.watch(userProvider).value;
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
