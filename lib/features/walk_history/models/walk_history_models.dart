import '../utils/walk_history_helpers.dart';

// ============================================================
// LOCATION
// ============================================================

class LocationData {
  final double lat;
  final double lng;

  const LocationData({
    required this.lat,
    required this.lng,
  });

  static LocationData? fromDynamic(dynamic value) {
    if (value is Map) {
      return LocationData(
        lat: doubleValue(value['lat']) ?? 0,
        lng: doubleValue(value['lng']) ?? 0,
      );
    }

    return null;
  }
}

// ============================================================
// ROUTE
// ============================================================

class RouteCoordinate {
  final double lat;
  final double lng;
  final int timestamp;

  const RouteCoordinate({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory RouteCoordinate.fromDynamic(dynamic value) {
    if (value is Map) {
      return RouteCoordinate(
        lat: doubleValue(value['lat']) ?? 0,
        lng: doubleValue(value['lng']) ?? 0,
        timestamp: intValue(value['timestamp']) ?? 0,
      );
    }

    return const RouteCoordinate(
      lat: 0,
      lng: 0,
      timestamp: 0,
    );
  }
}

List<RouteCoordinate> parseRouteCoordinates(dynamic value) {
  if (value is! List) {
    return [];
  }

  return value
      .map(RouteCoordinate.fromDynamic)
      .where(
        (point) => point.lat != 0 || point.lng != 0,
      )
      .toList();
}

// ============================================================
// WALK EVENT
// ============================================================

class WalkEvent {
  final String id;
  final String type;
  final String note;
  final String timestamp;

  const WalkEvent({
    required this.id,
    required this.type,
    required this.note,
    required this.timestamp,
  });

  factory WalkEvent.fromDynamic(dynamic value) {
    if (value is Map) {
      final data = Map<String, dynamic>.from(value);

      return WalkEvent(
        id: stringValue(data, 'id') ?? '',
        type: stringValue(data, 'type') ?? '',
        note: stringValue(data, 'note') ?? '',
        timestamp: stringValue(data, 'timestamp') ?? '',
      );
    }

    return const WalkEvent(
      id: '',
      type: '',
      note: '',
      timestamp: '',
    );
  }
}

List<WalkEvent> parseEvents(dynamic value) {
  if (value is! List) {
    return [];
  }

  return value
      .map(WalkEvent.fromDynamic)
      .where(
        (event) =>
            event.type.isNotEmpty ||
            event.note.isNotEmpty,
      )
      .toList();
}

// ============================================================
// ACTIVE WALK
// ============================================================

class ActiveWalkData {
  final String documentId;
  final String id;
  final String walkId;
  final String sessionId;

  final String ownerId;
  final String ownerName;

  final String walkerId;
  final String walkerUid;

  final String dogName;
  final String dogPhoto;

  final bool isActive;

  final double distanceKm;
  final int elapsedSeconds;

  final int peeCount;
  final int poopCount;

  final LocationData? location;

  const ActiveWalkData({
    required this.documentId,
    required this.id,
    required this.walkId,
    required this.sessionId,
    required this.ownerId,
    required this.ownerName,
    required this.walkerId,
    required this.walkerUid,
    required this.dogName,
    required this.dogPhoto,
    required this.isActive,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.peeCount,
    required this.poopCount,
    required this.location,
  });

  factory ActiveWalkData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return ActiveWalkData(
      documentId: documentId,
      id: stringValue(data, 'id') ?? documentId,
      walkId: stringValue(data, 'walkId') ??
          stringValue(data, 'id') ??
          '',
      sessionId: stringValue(data, 'sessionId') ?? '',
      ownerId: stringValue(data, 'ownerId') ?? '',
      ownerName: stringValue(data, 'ownerName') ?? '',
      walkerId: stringValue(data, 'walkerId') ??
          stringValue(data, 'walkerID') ??
          '',
      walkerUid: stringValue(data, 'walkerUid') ??
          stringValue(data, 'walkeruid') ??
          '',
      dogName: stringValue(data, 'dogName') ?? 'Dog',
      dogPhoto: stringValue(data, 'dogPhoto') ?? '',
      isActive: boolValue(data, 'isActive') ??
          boolValue(data, 'active') ??
          true,
      distanceKm: doubleValue(data['distanceKm']) ?? 0,
      elapsedSeconds: intValue(data['elapsedSeconds']) ?? 0,
      peeCount: intValue(data['peeCount']) ?? 0,
      poopCount: intValue(data['poopCount']) ?? 0,
      location: LocationData.fromDynamic(
        data['location'],
      ),
    );
  }
}

// ============================================================
// LIVE SESSION
// ============================================================

class LiveWalkSessionData {
  final String documentId;

  final String id;
  final String walkId;

  final String ownerId;
  final String ownerName;

  final String walkerId;
  final String walkerUid;

  final String dogName;
  final String dogPhoto;

  final double distanceKm;
  final int elapsedSeconds;

  final int peeCount;
  final int poopCount;

  final LocationData? location;

  final List<RouteCoordinate> routeCoordinates;
  final List<WalkEvent> events;

  const LiveWalkSessionData({
    required this.documentId,
    required this.id,
    required this.walkId,
    required this.ownerId,
    required this.ownerName,
    required this.walkerId,
    required this.walkerUid,
    required this.dogName,
    required this.dogPhoto,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.peeCount,
    required this.poopCount,
    required this.location,
    required this.routeCoordinates,
    required this.events,
  });

  factory LiveWalkSessionData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return LiveWalkSessionData(
      documentId: documentId,
      id: stringValue(data, 'id') ?? documentId,
      walkId: stringValue(data, 'walkId') ??
          stringValue(data, 'id') ??
          '',
      ownerId: stringValue(data, 'ownerId') ?? '',
      ownerName: stringValue(data, 'ownerName') ?? '',
      walkerId: stringValue(data, 'walkerId') ??
          stringValue(data, 'walkerID') ??
          '',
      walkerUid: stringValue(data, 'walkerUid') ??
          stringValue(data, 'walkeruid') ??
          '',
      dogName: stringValue(data, 'dogName') ?? 'Dog',
      dogPhoto: stringValue(data, 'dogPhoto') ?? '',
      distanceKm: doubleValue(data['distanceKm']) ?? 0,
      elapsedSeconds:
          intValue(data['elapsedSeconds']) ?? 0,
      peeCount: intValue(data['peeCount']) ?? 0,
      poopCount: intValue(data['poopCount']) ?? 0,
      location: LocationData.fromDynamic(
        data['location'],
      ),
      routeCoordinates:
          parseRouteCoordinates(data['routeCoordinates']),
      events: parseEvents(data['events']),
    );
  }
}

// ============================================================
// WALK HISTORY
// ============================================================

class WalkHistoryData {
  final String documentId;

  final String walkId;
  final String badge;

  final int createdAt;

  final String date;
  final String timeFormatted;

  final double distanceKm;
  final int durationMinutes;

  final String dogName;
  final String dogBreed;
  final String dogPhoto;

  final String ownerId;
  final String ownerName;

  final String walkerName;
  final String walkerId;
  final String walkerUid;

  final String walkerNote;
  final String walkerProfileImage;

  final int peeCount;
  final int poopCount;
  final int rating;

  const WalkHistoryData({
    required this.documentId,
    required this.walkId,
    required this.badge,
    required this.createdAt,
    required this.date,
    required this.timeFormatted,
    required this.distanceKm,
    required this.durationMinutes,
    required this.dogName,
    required this.dogBreed,
    required this.dogPhoto,
    required this.ownerId,
    required this.ownerName,
    required this.walkerName,
    required this.walkerId,
    required this.walkerUid,
    required this.walkerNote,
    required this.walkerProfileImage,
    required this.peeCount,
    required this.poopCount,
    required this.rating,
  });

  factory WalkHistoryData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return WalkHistoryData(
      documentId: documentId,
      walkId: stringValue(data, 'walkId') ??
          stringValue(data, 'id') ??
          documentId,
      badge: stringValue(data, 'badge') ?? '',
      createdAt: intValue(data['createdAt']) ?? 0,
      date: stringValue(data, 'date') ?? '',
      timeFormatted:
          stringValue(data, 'timeFormatted') ?? '',
      distanceKm: doubleValue(data['distanceKm']) ?? 0,
      durationMinutes:
          intValue(data['durationMinutes']) ?? 0,
      dogName: stringValue(data, 'dogName') ?? 'Dog',
      dogBreed: stringValue(data, 'dogBreed') ?? '',
      dogPhoto: stringValue(data, 'dogPhoto') ?? '',
      ownerId: stringValue(data, 'ownerId') ?? '-',
      ownerName:
          stringValue(data, 'ownerName') ?? 'Owner',
      walkerName:
          stringValue(data, 'walkerName') ?? 'Walker',
      walkerId: stringValue(data, 'walkerId') ?? '',
      walkerUid: stringValue(data, 'walkerUid') ??
          stringValue(data, 'walkeruid') ??
          '-',
      walkerNote:
          stringValue(data, 'walkerNote') ?? '',
      walkerProfileImage:
          stringValue(data, 'walkerProfileImage') ?? '',
      peeCount: intValue(data['peeCount']) ?? 0,
      poopCount: intValue(data['poopCount']) ?? 0,
      rating: intValue(data['rating']) ?? 0,
    );
  }
}
