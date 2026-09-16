import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/walker_availability_model.dart';

class WalkerAvailabilityService {
  WalkerAvailabilityService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Main walker collection.
  ///
  /// Walker profile/availability data is expected here.
  /// If your project already uses a different canonical walker
  /// collection, change only this constant.
  static const String walkersCollection = 'walkers';

  /// Realtime stream of all walkers.
  Stream<List<WalkerAvailabilityModel>> watchAllWalkers() {
    return _firestore
        .collection(walkersCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            WalkerAvailabilityModel.fromFirestore,
          )
          .where(
            (walker) => walker.walkerId.isNotEmpty,
          )
          .toList();
    });
  }

  /// Insta Walk availability.
  ///
  /// A walker appears only when:
  /// - Online
  /// - Searching for Insta Walk
  /// - No active/accepted walk
  Stream<List<WalkerAvailabilityModel>>
      watchInstaWalkAvailability() {
    return watchAllWalkers().map((walkers) {
      final available = walkers
          .where(
            (walker) => walker.isInstaWalkAvailable,
          )
          .toList();

      available.sort(
        (a, b) => a.walkerName
            .toLowerCase()
            .compareTo(
              b.walkerName.toLowerCase(),
            ),
      );

      return available;
    });
  }

  /// Daily Walk availability.
  ///
  /// Every walker having at least one booked slot is returned.
  ///
  /// No day-of-week is added or displayed by this service.
  Stream<List<WalkerAvailabilityModel>>
      watchDailyWalkAvailability() {
    return watchAllWalkers().map((walkers) {
      final available = walkers
          .where(
            (walker) =>
                walker.hasDailyWalkAvailability,
          )
          .toList();

      available.sort(
        (a, b) => a.walkerName
            .toLowerCase()
            .compareTo(
              b.walkerName.toLowerCase(),
            ),
      );

      return available;
    });
  }

  /// Realtime single walker.
  Stream<WalkerAvailabilityModel?>
      watchWalker(String walkerId) {
    return _firestore
        .collection(walkersCollection)
        .where(
          'uid',
          isEqualTo: walkerId,
        )
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      return WalkerAvailabilityModel.fromFirestore(
        snapshot.docs.first,
      );
    });
  }

  /// Get a single walker once.
  Future<WalkerAvailabilityModel?> getWalker(
    String walkerId,
  ) async {
    final snapshot = await _firestore
        .collection(walkersCollection)
        .where(
          'uid',
          isEqualTo: walkerId,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return WalkerAvailabilityModel.fromFirestore(
      snapshot.docs.first,
    );
  }

  /// Search a walker by UID.
  Future<List<WalkerAvailabilityModel>>
      searchWalkers(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllWalkers();
    }

    final walkers = await getAllWalkers();

    return walkers.where((walker) {
      final id = walker.walkerId.toLowerCase();
      final name = walker.walkerName.toLowerCase();

      return id.contains(normalizedQuery) ||
          name.contains(normalizedQuery);
    }).toList();
  }

  /// One-time fetch of all walkers.
  Future<List<WalkerAvailabilityModel>>
      getAllWalkers() async {
    final snapshot = await _firestore
        .collection(walkersCollection)
        .get();

    return snapshot.docs
        .map(
          WalkerAvailabilityModel.fromFirestore,
        )
        .where(
          (walker) => walker.walkerId.isNotEmpty,
        )
        .toList();
  }

  /// Format slots for compact Admin display.
  ///
  /// Example:
  /// 07:00–08:00 AM, 10:00–11:00 AM
  String formatSlots(
    List<String> slots,
  ) {
    if (slots.isEmpty) {
      return 'No booked slots';
    }

    return slots
        .map(_formatSlot)
        .where(
          (slot) => slot.isNotEmpty,
        )
        .join(', ');
  }

  String _formatSlot(String slot) {
    final value = slot.trim();

    if (value.isEmpty) {
      return '';
    }

    // Already formatted by the walker app.
    if (value.contains('–')) {
      return value;
    }

    if (value.contains(' - ')) {
      return value.replaceAll(
        ' - ',
        '–',
      );
    }

    return value;
  }
}
