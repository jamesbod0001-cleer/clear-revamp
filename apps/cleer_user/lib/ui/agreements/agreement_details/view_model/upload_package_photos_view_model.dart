import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/storage/storage_use_case.dart';
import 'package:cleer/ui/agreements/agreement_details/state/upload_package_photos_state.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/process_image_result/process_image_result.dart';
import 'package:cleer_core/models/upload_image_result/upload_image_result.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_package_photos_view_model.g.dart';

@riverpod
class UploadPackagePhotosViewModel extends _$UploadPackagePhotosViewModel {
  final _log = AmplifyLogger("UploadPackagePhotosViewModel");

  @override
  FutureOr<UploadPackagePhotosState> build(String agreementId) {
    pickAndProcessImages = Command.createAsyncNoResult(
      _pickAndProcessImages,
      errorFilter: const LocalErrorFilter(),
    );
    return UploadPackagePhotosState();
  }

  late Command<int, void> pickAndProcessImages;

  Future<void> _pickAndProcessImages(int limit) async {
    List<XFile> pickedImagesXFiles;
    if (limit > 1) {
      final pickedImagesResult = await ref
          .read(storageUseCaseProvider.notifier)
          .pickMultipleImages(limit);
      if (pickedImagesResult.isError()) {
        _log.error(
          'Error picking images',
          pickedImagesResult.exceptionOrNull(),
        );
        throw pickedImagesResult.exceptionOrNull()!;
      }
      pickedImagesXFiles = pickedImagesResult.getOrNull()!;
    } else {
      final pickedImageResult = await ref
          .read(storageUseCaseProvider.notifier)
          .pickImage();
      if (pickedImageResult.isError()) {
        _log.error('Error picking image', pickedImageResult.exceptionOrNull());
        throw pickedImageResult.exceptionOrNull()!;
      }
      pickedImagesXFiles = [pickedImageResult.getOrNull()!];
    }

    List<ProcessImageDomainResult> processedImages = [];

    for (final imageXFile in pickedImagesXFiles) {
      final processImageResult = await ref
          .read(storageUseCaseProvider.notifier)
          .processImage(
            ProcessImageParams(
              originalFile: imageXFile,
              width: 1200,
              height: 1200,
            ),
          );
      if (processImageResult.isError()) {
        _log.error(
          'Error processing image',
          processImageResult.exceptionOrNull(),
        );
        throw processImageResult.exceptionOrNull()!;
      }
      final processedImage = processImageResult.getOrNull()!;
      processedImages.add(processedImage);
    }

    state = AsyncData(
      state.requireValue.copyWith(
        selectedImages: [
          ...state.requireValue.selectedImages,
          ...processedImages,
        ],
      ),
    );
  }

  void removeImage(int index) {
    List<ProcessImageDomainResult> selectedImages = [
      ...state.requireValue.selectedImages,
    ];
    selectedImages.removeAt(index);
    state = AsyncValue.data(
      state.requireValue.copyWith(selectedImages: selectedImages),
    );
  }

  // Future<void> saveAndContinue() async {
  //   _log.info(
  //     'Attempting to save packaging photos and continue for agreement: $agreementId',
  //   );
  //   state = const AsyncValue.loading();
  //   state = await AsyncValue.guard(() async {
  //     final agreementResult = await ref
  //         .read(agreementUseCaseProvider.notifier)
  //         .getAgreement(agreementId);
  //
  //     if (agreementResult.isError()) {
  //       _log.error('Error getting agreement $agreementId}');
  //       throw agreementResult.exceptionOrNull()!;
  //     }
  //
  //     final agreement = agreementResult.getOrNull()!;
  //     _log.info('Successfully retrieved agreement $agreementId');
  //
  //     final uploadTasks = state.requireValue.selectedImages
  //         .asMap()
  //         .entries
  //         .map<Future<UploadImageResult>>((entry) async {
  //           final index = entry.key + 1;
  //           final processedImage = entry.value;
  //           final String fullPath =
  //               'agreements/${agreement.id}/packaging/${DateTime.now().millisecondsSinceEpoch}_${index}_${processedImage.file.name}';
  //           final uploadImageResult = await ref
  //               .read(storageUseCaseProvider.notifier)
  //               .uploadImage(
  //                 processedImageResult: processedImage,
  //                 fullPath: fullPath,
  //                 altText: 'Packaging Photo $index',
  //               );
  //           if (uploadImageResult.isError()) {
  //             _log.error(
  //               'Error uploading packaging Photo $index',
  //               uploadImageResult.exceptionOrNull(),
  //             );
  //             throw Failure(uploadImageResult.exceptionOrNull()!);
  //           }
  //           return uploadImageResult.getOrNull()!;
  //         });
  //
  //     final List<UploadImageResult> uploadResults = await Future.wait(
  //       uploadTasks,
  //     );
  //     _log.info(
  //       'Successfully uploaded ${uploadResults.length} packaging photos',
  //     );
  //
  //     final updateAgreementResult = await ref
  //         .read(agreementUseCaseProvider.notifier)
  //         .updateAgreement(
  //           agreement.copyWith(
  //             physicalDeliveryContext: agreement.physicalDeliveryContext!
  //                 .copyWith(
  //                   status: .awaitingDispatch,
  //                   packagingPhotos: uploadResults
  //                       .map((uploadResult) => uploadResult.toPhoto())
  //                       .toList(),
  //                 ),
  //           ),
  //         );
  //     return updateAgreementResult.fold(
  //       (updatedAgreement) {
  //         _log.info(
  //           'Successfully updated agreement $agreementId with packaging photos',
  //         );
  //         return state.requireValue;
  //       },
  //       (failure) {
  //         _log.error('Error updating agreement $agreementId', failure);
  //         throw failure;
  //       },
  //     );
  //   });
  // }

  Future<void> saveAndContinue() async {
    _log.info(
      'Attempting to save packaging photos and continue for agreement: $agreementId',
    );

    final keepAliveLink = ref.keepAlive();

    state = const AsyncValue.loading();

    try {
      final agreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .getAgreement(agreementId);

      if (agreementResult.isError()) {
        _log.error('Error getting agreement $agreementId');
        throw agreementResult.exceptionOrNull()!;
      }

      final agreement = agreementResult.getOrNull()!;
      _log.info('Successfully retrieved agreement $agreementId');

      final uploadTasks = state.requireValue.selectedImages
          .asMap()
          .entries
          .map<Future<UploadImageResult>>((entry) async {
            final index = entry.key + 1;
            final processedImage = entry.value;
            final String fullPath =
                'agreements/${agreement.id}/packaging/${DateTime.now().millisecondsSinceEpoch}_${index}_${processedImage.file.name}';
            final uploadImageResult = await ref
                .read(storageUseCaseProvider.notifier)
                .uploadImage(
                  processedImageResult: processedImage,
                  fullPath: fullPath,
                  altText: 'Packaging Photo $index',
                );
            if (uploadImageResult.isError()) {
              _log.error(
                'Error uploading packaging Photo $index',
                uploadImageResult.exceptionOrNull(),
              );
              throw Failure(uploadImageResult.exceptionOrNull()!);
            }
            return uploadImageResult.getOrNull()!;
          });

      final List<UploadImageResult> uploadResults = await Future.wait(
        uploadTasks,
      );
      _log.info(
        'Successfully uploaded ${uploadResults.length} packaging photos',
      );

      final updateAgreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .updateAgreement(
            agreement.copyWith(
              physicalDeliveryContext: agreement.physicalDeliveryContext!
                  .copyWith(
                    status: .awaitingDispatch,
                    packagingPhotos: uploadResults
                        .map((uploadResult) => uploadResult.toPhoto())
                        .toList(),
                  ),
            ),
          );

      updateAgreementResult.fold(
        (updatedAgreement) {
          _log.info(
            'Successfully updated agreement $agreementId with packaging photos',
          );
        },
        (failure) {
          _log.error('Error updating agreement $agreementId', failure);
          state = AsyncValue.error(failure, StackTrace.current);
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      keepAliveLink.close();
    }
  }

  Future<void> skip() async {
    _log.info(
      'Attempting to skip packaging photos for agreement: $agreementId',
    );

    // Prevent premature disposal when the parent widget unmounts this card
    final keepAliveLink = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      final agreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .getAgreement(agreementId);

      if (agreementResult.isError()) {
        _log.error('Error getting agreement $agreementId');
        state = AsyncValue.error(
          agreementResult.exceptionOrNull()!,
          StackTrace.current,
        );
        return;
      }

      final agreement = agreementResult.getOrNull()!;
      _log.info('Successfully retrieved agreement $agreementId');

      final updateAgreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .updateAgreement(
            agreement.copyWith(
              physicalDeliveryContext: agreement.physicalDeliveryContext!
                  .copyWith(status: .awaitingDispatch),
            ),
          );

      updateAgreementResult.fold(
        (updatedAgreement) {
          _log.info(
            'Successfully skipped packaging photos for agreement $agreementId',
          );
        },
        (failure) {
          _log.error(
            'Error skipping packaging photos for $agreementId',
            failure,
          );
          state = AsyncValue.error(failure, StackTrace.current);
        },
      );
    } catch (e, stack) {
      _log.error('Unexpected crash in skip flow', e);
      state = AsyncValue.error(e, stack);
    } finally {
      // Safely release the provider lock so Riverpod can clean it up
      keepAliveLink.close();
    }
  }

  // Future<void> skip() async {
  //   _log.info(
  //     'Attempting to skip packaging photos for agreement: $agreementId',
  //   );
  //   state = const AsyncValue.loading();
  //   state = await AsyncValue.guard(() async {
  //     final agreementResult = await ref
  //         .read(agreementUseCaseProvider.notifier)
  //         .getAgreement(agreementId);
  //
  //     if (agreementResult.isError()) {
  //       _log.error('Error getting agreement $agreementId}');
  //       throw agreementResult.exceptionOrNull()!;
  //     }
  //
  //     final agreement = agreementResult.getOrNull()!;
  //     _log.info('Successfully retrieved agreement $agreementId');
  //
  //     final updateAgreementResult = await ref
  //         .read(agreementUseCaseProvider.notifier)
  //         .updateAgreement(
  //           agreement.copyWith(
  //             physicalDeliveryContext: agreement.physicalDeliveryContext!
  //                 .copyWith(status: .awaitingDispatch),
  //           ),
  //         );
  //     return updateAgreementResult.fold(
  //       (updatedAgreement) {
  //         _log.info(
  //           'Successfully skipped packaging photos for agreement $agreementId',
  //         );
  //         return state.requireValue;
  //       },
  //       (failure) {
  //         _log.error(
  //           'Error skipping packaging photos for $agreementId',
  //           failure,
  //         );
  //         throw failure;
  //       },
  //     );
  //   });
  // }
}
