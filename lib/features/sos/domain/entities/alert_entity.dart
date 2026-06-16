enum TriggerType { manual, immobility, wearable }

enum DeliveryStatus { pending, sent, failed }

class AlertEntity {
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

  const AlertEntity({
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

  bool get isCancelled => cancelledAt != null;
  bool get hasVideo => videoUrl != null;
  bool get hasLocation => latitude != 0.0 || longitude != 0.0;
}
