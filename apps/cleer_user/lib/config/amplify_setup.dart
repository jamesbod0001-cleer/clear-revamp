import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_push_notifications_pinpoint/amplify_push_notifications_pinpoint.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:cleer/amplify_outputs.dart';
// ignore: implementation_imports
import 'package:cleer_api/src/models/ModelProvider.dart';
import 'package:flutter/foundation.dart';

Future<void> configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final api = AmplifyAPI(
      options: APIPluginOptions(modelProvider: ModelProvider.instance),
    );
    final storage = AmplifyStorageS3();
    if (!kIsWeb) {
      final notifications = AmplifyPushNotificationsPinpoint();
      await Amplify.addPlugins([auth, api, storage, notifications]);
    } else {
      await Amplify.addPlugins([auth, api, storage]);
    }
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}
