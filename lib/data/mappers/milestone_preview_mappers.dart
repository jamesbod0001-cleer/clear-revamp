import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cleer/data/amplify_models/ModelProvider.dart' as amplify_model;
import 'package:cleer/data/mappers/agreement_mappers.dart';
import 'package:cleer/domain/models/milestone/milestone_preview.dart' as domain;
import 'package:cleer/domain/models/milestone/milestone_enums.dart';
import 'package:intl/intl.dart';

/// Extensions on the Amplify MilestonePreview custom type to convert it to the Domain Task entity.
extension MilestonePreviewToDomainMapper on amplify_model.MilestonePreview {
  domain.MilestonePreview toDomain() {
    return domain.MilestonePreview(
      id: id,
      order: order,
      name: name,
      amount: amount,
      expectedReleaseDate: expectedReleaseDate.getDateTime(),
    );
  }
}

/// Extensions on the Domain MilestonePreview entity to convert it back to the Amplify custom type for mutations.
extension MilestonePreviewToAmplifyMapper on domain.MilestonePreview {
  amplify_model.MilestonePreview toAmplify() {
    return amplify_model.MilestonePreview(
      id: id,
      order: order,
      name: name,
      amount: amount,
      expectedReleaseDate: TemporalDate.fromString(
        DateFormat('yyyy-MM-dd').format(expectedReleaseDate),
      ),
    );
  }
}