import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amplify_providers.g.dart';

@Riverpod(keepAlive: true)
AuthCategory amplifyAuth(Ref ref) => Amplify.Auth;

@Riverpod(keepAlive: true)
AmplifyHub amplifyHub(Ref ref) => Amplify.Hub;

@Riverpod(keepAlive: true)
APICategory amplifyAPI(Ref ref) => Amplify.API;

@Riverpod(keepAlive: true)
StorageCategory amplifyStorage(Ref ref) => Amplify.Storage;

@Riverpod(keepAlive: true)
PushNotificationsCategory amplifyPushNotifications(Ref ref) =>
    Amplify.Notifications.Push;
