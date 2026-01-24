import 'package:cleer/data/repositories/flutterwave/flutterwave_repository.dart';
import 'package:cleer/domain/models/bank/bank.dart';
import 'package:cleer/domain/models/enums/country_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutterwave_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Bank>> getBanks(Ref ref, CountryCode countryCode) async {
  final repository = ref.watch(flutterwaveRepositoryProvider);

  final result = await repository.getBanks(countryCode);
  return result.fold((banks) => banks, (failure) => throw failure);
}
