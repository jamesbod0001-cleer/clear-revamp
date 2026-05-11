import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart' hide SignedOutException;
import 'package:cleer/data/repositories/api/user/user_repository.dart';
import 'package:cleer/domain/failures/data_failures.dart';
import 'package:cleer/domain/models/upload_image_result/upload_image_result.dart';
import 'package:cleer/domain/models/user/user.dart';
import 'package:cleer/domain/providers/user/user_provider.dart';
import 'package:cleer/domain/use_cases/storage/params/process_image_params.dart';
import 'package:cleer/domain/use_cases/storage/storage_use_case.dart';
import 'package:path/path.dart' as p;
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_use_case.g.dart';

@Riverpod(keepAlive: true)
class UserUseCase extends _$UserUseCase {
  late final UserRepository _userRepository;

  final _log = AmplifyLogger("UserUseCase");

  @override
  void build() {
    _userRepository = ref.watch(userRepositoryProvider);
    return;
  }

  Future<ResultDart<User, DataFailure>> updateUserProfile(User user) async {
    final result = await _userRepository.updateUserProfile(user);
    result.fold(
      (user) {
        _log.info("User updated successfully");
      },
      (failure) {
        _log.error("User update failed");
      },
    );
    return result;
  }

  Future<ResultDart<void, Object>> pickAndUploadProfilePicture() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _log.error('User state not found');
      return Failure(DataFailure.notFound());
    }
    _log.info('Uploading profile picture');

    final pickImageResult = await ref
        .read(storageUseCaseProvider.notifier)
        .pickImage();
    if (pickImageResult.isError()) {
      _log.error('Error picking image', pickImageResult.exceptionOrNull());
      return Failure(pickImageResult.exceptionOrNull()!);
    }
    final imageXFile = pickImageResult.getOrNull()!;

    if (user.profilePicture != null) {
      await ref
          .read(storageUseCaseProvider.notifier)
          .deleteFile(user.profilePicture!.key);
      // There is no need to update it here
      // // We update the DB to null so the UI instantly clears the old image
      // await updateUserProfile(user.copyWith(profilePicture: null));
      _log.info('Old profile picture deleted');
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
    if (processImageResult.isError()) {
      _log.error(
        'Error processing image',
        processImageResult.exceptionOrNull(),
      );
      return Failure(processImageResult.exceptionOrNull()!);
    }
    final processedImage = processImageResult.getOrNull()!;

    final String extension = p.extension(processedImage.file.path).isEmpty
        ? '.jpg'
        : p.extension(processedImage.file.path);
    final String fullPath =
        'public/users/${user.identityId}/profile_picture_${DateTime.now().millisecondsSinceEpoch}$extension';

    final uploadImageResult = await ref
        .read(storageUseCaseProvider.notifier)
        .uploadImage(
      processedImageResult: processedImage,
      fullPath: fullPath,
      altText: 'Profile picture',
    );
    if (uploadImageResult.isError()) {
      _log.error(
        'Error uploading profile picture',
        uploadImageResult.exceptionOrNull(),
      );
      return Failure(uploadImageResult.exceptionOrNull()!);
    }
    final uploadedImageResult = uploadImageResult.getOrNull()!;

    _log.info('Profile picture uploaded to AWS, updating user profile...');
    final updateResult = await _userRepository.updateUserProfile(
      user.copyWith(profilePicture: uploadedImageResult.toPhoto()),
    );

    if (updateResult.isError()) {
      _log.error('Error updating user profile', updateResult.exceptionOrNull());
      return Failure(updateResult.exceptionOrNull()!);
    }

    _log.info('Profile picture flow completed successfully!');
    return Success.unit();
  }
}
