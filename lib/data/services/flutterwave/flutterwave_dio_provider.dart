import 'package:cleer/data/services/local/secure_storage_service.dart';
import 'package:cleer/env/env.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutterwave_dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio flutterwaveDio(Ref ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageServiceProvider);

  dio.options.baseUrl = Env.flutterwaveIsLive
      ? 'https://api.flutterwave.com/v4'
      : 'https://developersandbox-api.flutterwave.com';

  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await storage.getFlutterwaveToken();
        bool needsRefresh =
            token == null || JwtDecoder.getRemainingTime(token).inSeconds < 60;
        if (needsRefresh) {
          try {
            final authDio = Dio();
            final response = await authDio.post(
              'https://idp.flutterwave.com/realms/flutterwave/protocol/openid-connect/token',
              data: {
                'client_id': Env.flutterwaveClientId,
                'client_secret': Env.flutterwaveClientSecret,
                'grant_type': 'client_credentials',
              },
              options: Options(contentType: Headers.formUrlEncodedContentType),
            );

            token = response.data['access_token'];
            if (token != null) {
              await storage.saveFlutterwaveToken(token);
            }
          } catch (e) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Auth Refresh Failed',
              ),
            );
          }
        }
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // If the token was revoked or expired early (401)
        if (e.response?.statusCode == 401) {
          await storage.clearFlutterwaveToken();
          // The next request will automatically trigger the refresh logic above
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
}
