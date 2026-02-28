import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/upload_image_result/upload_image_result.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/storage/params/process_image_params.dart';
import 'package:cleer/domain/use_cases/storage/storage_use_case.dart';
import 'package:cleer/domain/use_cases/user/user_use_case.dart';
import 'package:command_it/command_it.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;

part 'account_security_view_model.g.dart';

@riverpod
class AccountSecurityViewModel extends _$AccountSecurityViewModel {
  final _log = AmplifyLogger("AccountSecurityViewModel");

  @override
  FutureOr<void> build() async {
    uploadProfilePicture = Command.createAsyncNoParamNoResult(
      _uploadProfilePicture,
      errorFilter: const LocalErrorFilter(),
    );
  }

  late Command<void, void> uploadProfilePicture;

  Future<void> _uploadProfilePicture() async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      _log.error('User state not found');
      throw Failure(DataFailure.notFound());
    }
    _log.info('Uploading profile picture');
    final pickImageResult = await ref
        .read(storageUseCaseProvider.notifier)
        .pickImage();
    await pickImageResult.fold(
      (imageXFile) async {
        if (user.profilePicture != null) {
          await ref
              .read(storageUseCaseProvider.notifier)
              .deleteFile(user.profilePicture!.key);
          await ref
              .read(userUseCaseProvider.notifier)
              .updateUserProfile(user.copyWith(profilePicture: null));
          _log.info('Profile picture deleted');
        }
        final processImageResult = await ref
            .read(storageUseCaseProvider.notifier)
            .processImage(
              ProcessImageParams(
                originalFile: File(imageXFile.path),
                width: 400,
                height: 400,
              ),
            );
        await processImageResult.fold(
          (processedImage) async {
            final String extension =
                p.extension(processedImage.file.path).isEmpty
                ? '.jpg'
                : p.extension(processedImage.file.path);
            final String fullPath =
                'public/users/${user.identityId}/profile_picture$extension';

            final uploadImageResult = await ref
                .read(storageUseCaseProvider.notifier)
                .uploadImage(
                  processedImageResult: processedImage,
                  fullPath: fullPath,
                  altText: 'Profile picture',
                );

            await uploadImageResult.fold(
              (result) async {
                _log.info('Profile picture uploaded');
                await ref
                    .read(userUseCaseProvider.notifier)
                    .updateUserProfile(
                      user.copyWith(profilePicture: result.toPhoto()),
                    );
              },
              (failure) {
                _log.error('Error uploading profile picture', failure);
                throw failure;
              },
            );
          },
          (failure) {
            _log.error('Error processing image', failure);
            throw failure;
          },
        );
      },
      (failure) {
        _log.error('Error uploading profile picture', failure);
        throw failure;
      },
    );
  }
}
