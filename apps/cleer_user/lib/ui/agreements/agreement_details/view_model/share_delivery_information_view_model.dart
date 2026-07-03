import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/domain/use_cases/agreement/agreement_use_case.dart';
import 'package:cleer/domain/use_cases/storage/storage_use_case.dart';
import 'package:cleer/ui/agreements/agreement_details/state/share_delivery_information_state.dart';
import 'package:cleer_core/cleer_core.dart';
import 'package:cleer_core/models/process_image_result/process_image_result.dart';
import 'package:cleer_core/models/upload_image_result/upload_image_result.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_delivery_information_view_model.g.dart';

@riverpod
class ShareDeliveryInformationViewModel
    extends _$ShareDeliveryInformationViewModel {
  final _log = AmplifyLogger("ShareDeliveryInformationViewModel");

  @override
  FutureOr<ShareDeliveryInformationState> build(String agreementId) {
    pickAndProcessEvidenceImages = Command.createAsyncNoResult(
      _pickAndProcessEvidenceImages,
      errorFilter: const LocalErrorFilter(),
    );

    return ShareDeliveryInformationState(
      formData: ShareDeliveryInformationFormData.empty(),
    );
  }

  late Command<int, void> pickAndProcessEvidenceImages;

  Future<void> _pickAndProcessEvidenceImages(int limit) async {
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
        formData: state.requireValue.formData.copyWith(
          evidenceImages: [
            ...state.requireValue.formData.evidenceImages,
            ...processedImages,
          ],
        ),
      ),
    );
  }

  void removeImage(int index) {
    List<ProcessImageDomainResult> selectedImages = [
      ...state.requireValue.formData.evidenceImages,
    ];
    selectedImages.removeAt(index);
    state = AsyncValue.data(
      state.requireValue.copyWith(
        formData: state.requireValue.formData.copyWith(
          evidenceImages: selectedImages,
        ),
      ),
    );
  }

  Future<void> shareDeliveryDetails() async {
    _log.info(
      'Attempting to save sharing delivery details for agreement: $agreementId',
    );

    final formData = state.requireValue.formData;

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

      List<UploadImageResult>? uploadResults;
      if (formData.evidenceImages.isNotEmpty) {
        final uploadTasks = formData.evidenceImages
            .asMap()
            .entries
            .map<Future<UploadImageResult>>((entry) async {
              final index = entry.key + 1;
              final processedImage = entry.value;
              final String fullPath =
                  'agreements/${agreement.id}/delivery/${DateTime.now().millisecondsSinceEpoch}_${index}_${processedImage.file.name}';
              final uploadImageResult = await ref
                  .read(storageUseCaseProvider.notifier)
                  .uploadImage(
                    processedImageResult: processedImage,
                    fullPath: fullPath,
                    altText: 'Delivery Photo $index',
                  );
              if (uploadImageResult.isError()) {
                _log.error(
                  'Error uploading delivery evidence photo $index',
                  uploadImageResult.exceptionOrNull(),
                );
                throw Failure(uploadImageResult.exceptionOrNull()!);
              }
              return uploadImageResult.getOrNull()!;
            });

        uploadResults = await Future.wait(uploadTasks);
        _log.info(
          'Successfully uploaded ${uploadResults.length} delivery evidence photos',
        );
      }

      final cleanDigits = formData.driverPhoneNumber.replaceAll(' ', '');
      final fullE164Number = '+234$cleanDigits';

      final updateAgreementResult = await ref
          .read(agreementUseCaseProvider.notifier)
          .updateAgreement(
            agreement.copyWith(
              physicalDeliveryContext: agreement.physicalDeliveryContext!
                  .copyWith(
                    status: .awaitingBuyerAcknowledgment,
                    deliveryDetails: DeliveryDetails(
                      driverPhoneNumber: fullE164Number,
                      additionalDetails: formData.deliveryInformation,
                      arrangedBy: formData.arrangedBy!,
                      photos: uploadResults
                          ?.map((uploadResult) => uploadResult.toPhoto())
                          .toList(),
                    ),
                  ),
            ),
          );

      updateAgreementResult.fold(
        (updatedAgreement) {
          _log.info(
            'Successfully updated agreement $agreementId with sharing delivery details',
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
      'Attempting to skip sharing delivery details for agreement: $agreementId',
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
                  .copyWith(status: .inTransit),
            ),
          );

      updateAgreementResult.fold(
        (updatedAgreement) {
          _log.info(
            'Successfully skipped sharing delivery details for agreement $agreementId',
          );
        },
        (failure) {
          _log.error(
            'Error skipping sharing delivery details for $agreementId',
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

  void onFormChanged(ShareDeliveryInformationFormData formData) {
    if (state.hasValue) {
      _log.info('ShareDeliveryInformation form changed: $formData');
      state = AsyncValue.data(state.value!.copyWith(formData: formData));
    }
  }
}

extension ShareDeliveryInformationFormDataExtension
    on ShareDeliveryInformationFormData {
  bool get isValid =>
      driverPhoneNumber.isValidPhone &&
      deliveryInformation.isNotEmpty &&
      arrangedBy != null;
}
