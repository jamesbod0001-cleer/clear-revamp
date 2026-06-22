import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_route_provider.g.dart';

@Riverpod(keepAlive: true)
class PendingRoute extends _$PendingRoute {
  @override
  String? build() => null;

  void setRoute(String route) => state = route;

  void consume() => state = null;
}
