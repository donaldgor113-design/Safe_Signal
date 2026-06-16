import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_signal/features/sos/domain/entities/alert_entity.dart';

class AlertModel {
  final String id;
  final String userId;
  final String scenarioId;
  final DateTime triggeredAt;
  final TriggerType triggerType;
  final double latitude;
  final double longitude;
  final String? locationAddress;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final List<String> sentChannels;
  final Map<String, DeliveryStatus> deliveryStatus;
  final DateTime? cancelledAt;

  const AlertModel({
    required this.id,
    required this.userId,
    required this.scenarioId,
    required this.triggeredAt,
    required this.triggerType,
    required this.latitude,
    required this.longitude,
    this.locationAddress,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.sentChannels = const [],
    this.deliveryStatus = const {},
    this.cancelledAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final geoPoint = data['location'] as GeoPoint?;
    final deliveryMap = data['deliveryStatus'] as Map<String, dynamic>? ?? {};

    return AlertModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      scenarioId: data['scenarioId'] as String? ?? '',
      triggeredAt: (data['triggeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      triggerType: TriggerType.values.firstWhere(
        (t) => t.name == data['triggerType'],
        orElse: () => TriggerType.manual,
      ),
      latitude: geoPoint?.latitude ?? 0.0,
      longitude: geoPoint?.longitude ?? 0.0,
      locationAddress: data['locationAddress'] as String?,
      videoUrl: data['videoUrl'] as String?,
      videoThumbnailUrl: data['videoThumbnailUrl'] as String?,
      sentChannels: (data['sentChannels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      deliveryStatus: deliveryMap.map(
        (k, v) => MapEntry(
          k,
          DeliveryStatus.values.firstWhere(
            (d) => d.name == v,
            orElse: () => DeliveryStatus.pending,
          ),
        ),
      ),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'scenarioId': scenarioId,
        'triggeredAt': FieldValue.serverTimestamp(),
        'triggerType': triggerType.name,
        'location': GeoPoint(latitude, longitude),
        'locationAddress': locationAddress,
        'videoUrl': videoUrl,
        'videoThumbnailUrl': videoThumbnailUrl,
        'sentChannels': sentChannels,
        'deliveryStatus': deliveryStatus.map((k, v) => MapEntry(k, v.name)),
        'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      };

  AlertEntity toEntity() => AlertEntity(
        id: id,
        userId: userId,
        scenarioId: scenarioId,
        triggeredAt: triggeredAt,
        triggerType: triggerType,
        latitude: latitude,
        longitude: longitude,
        locationAddress: locationAddress,
        videoUrl: videoUrl,
        videoThumbnailUrl: videoThumbnailUrl,
        sentChannels: sentChannels,
        deliveryStatus: deliveryStatus,
        cancelledAt: cancelledAt,
      );

  AlertModel copyWith({
    String? videoUrl,
    String? locationAddress,
    List<String>? sentChannels,
    Map<String, DeliveryStatus>? deliveryStatus,
  }) {
    return AlertModel(
      id: id,
      userId: userId,
      scenarioId: scenarioId,
      triggeredAt: triggeredAt,
      triggerType: triggerType,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl,
      sentChannels: sentChannels ?? this.sentChannels,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      cancelledAt: cancelledAt,
    );
  }
}
