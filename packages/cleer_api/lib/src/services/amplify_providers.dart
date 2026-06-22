import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amplify_providers.g.dart';

@riverpod
AuthCategory amplifyAuth(Ref ref) => Amplify.Auth;

@riverpod
AmplifyHub amplifyHub(Ref ref) => Amplify.Hub;

@riverpod
APICategory amplifyAPI(Ref ref) => Amplify.API;

@riverpod
StorageCategory amplifyStorage(Ref ref) => Amplify.Storage;

@riverpod
PushNotificationsCategory amplifyPushNotifications(Ref ref) =>
    Amplify.Notifications.Push;
