import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/walker_availability_model.dart';

class WalkerAvailabilityService {
  WalkerAvailabilityService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String walkersCollection = 'walkers';
  static const String dailyAvailabilityCollection =
      'daily_walk_availability';

  // ============================================================
  // ALL WALKERS
  // Source: walkers
  // Walker ID = walkers.uid
  // ============================================================

  Stream<List<WalkerAvailabilityModel>> watchAllWalkers() {
    return _firestore
        .collection(walkersCollection)
        .snapshots()
        .asyncMap(_buildWalkerAvailabilityList);
  }

  // ============================================================
  // INSTA WALK
  //
  // Only show:
  // - Online
  // - Searching for Insta Walk
  // - No active/accepted walk
  //
  // Source: walkers
  // ============================================================

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

  // ============================================================
  // DAILY WALK
  //
  // Walker details:
  //   walkers.uid
  //
  // Daily slots:
  //   daily_walk_availability.walkerId
  //
  // Only isActive == true slots are included.
  // ============================================================

  Stream<List<WalkerAvailabilityModel>>
      watchDailyWalkAvailability() {
    return _firestore
        .collection(walkersCollection)
        .snapshots()
        .asyncMap(_buildWalkerAvailabilityList);
  }

  // ============================================================
  // BUILD WALKER LIST
  // ============================================================

  Future<List<WalkerAvailabilityModel>>
      _buildWalkerAvailabilityList(
    QuerySnapshot<Map<String, dynamic>> walkerSnapshot,
  ) async {
    if (walkerSnapshot.docs.isEmpty) {
      return const [];
    }

    // ----------------------------------------------------------
    // Fetch active Daily Walk availability records.
    // ----------------------------------------------------------

    final dailySnapshot = await _firestore
        .collection(dailyAvailabilityCollection)
        .where(
          'isActive',
          isEqualTo: true,
        )
        .get();

    // ----------------------------------------------------------
    // Group Daily Walk slots by walkerId.
    //
    // daily_walk_availability.walkerId
    //                  ↓
    //              walkers.uid
    // ----------------------------------------------------------

    final Map<String, List<String>> slotsByWalker =
        <String, List<String>>{};

    for (final doc in dailySnapshot.docs) {
      final data = doc.data();

      final walkerId = _stringValue(
        data['walkerId'],
      );

      if (walkerId.isEmpty) {
        continue;
      }

      final startTime = _stringValue(
        data['startTime'],
      );

      final endTime = _stringValue(
        data['endTime'],
      );

      if (startTime.isEmpty && endTime.isEmpty) {
        continue;
      }

      final slot = _formatSlot(
        startTime,
        endTime,
      );

      if (slot.isEmpty) {
        continue;
      }

      slotsByWalker
          .putIfAbsent(
            walkerId,
            () => <String>[],
          )
          .add(slot);
    }

    // ----------------------------------------------------------
    // Build final WalkerAvailabilityModel list.
    // ----------------------------------------------------------

    final result = <WalkerAvailabilityModel>[];

    for (final doc in walkerSnapshot.docs) {
      final walker =
          WalkerAvailabilityModel.fromFirestore(doc);

      if (walker.walkerId.isEmpty) {
        continue;
      }

      final dailySlots =
          slotsByWalker[walker.walkerId] ??
              const <String>[];

      result.add(
        walker.copyWith(
          dailyWalkSlots: _sortSlots(
            dailySlots,
          ),
        ),
      );
    }

    return result;
  }

  // ============================================================
  // WATCH ONE WALKER
  // ============================================================

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
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final walkers =
          await _buildWalkerAvailabilityList(
        snapshot,
      );

      if (walkers.isEmpty) {
        return null;
      }

      return walkers.first;
    });
  }

  // ============================================================
  // GET ONE WALKER
  // ============================================================

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

    final walkers =
        await _buildWalkerAvailabilityList(
      snapshot,
    );

    if (walkers.isEmpty) {
      return null;
    }

    return walkers.first;
  }

  // ============================================================
  // GET ALL WALKERS
  // ============================================================

  Future<List<WalkerAvailabilityModel>>
      getAllWalkers() async {
    final snapshot = await _firestore
        .collection(walkersCollection)
        .get();

    return _buildWalkerAvailabilityList(
      snapshot,
    );
  }

  // ============================================================
  // SEARCH WALKERS
  // ============================================================

  Future<List<WalkerAvailabilityModel>>
      searchWalkers(String query) async {
    final normalizedQuery =
        query.trim().toLowerCase();

    final walkers = await getAllWalkers();

    if (normalizedQuery.isEmpty) {
      return walkers;
    }

    return walkers.where((walker) {
      final id =
          walker.walkerId.toLowerCase();

      final name =
          walker.walkerName.toLowerCase();

      return id.contains(normalizedQuery) ||
          name.contains(normalizedQuery);
    }).toList();
  }

  // ============================================================
  // FORMAT SLOTS
  // ============================================================

  String formatSlots(
    List<String> slots,
  ) {
    if (slots.isEmpty) {
      return 'No booked slots';
    }

    return _sortSlots(slots)
        .join(', ');
  }

  String _formatSlot(
    String startTime,
    String endTime,
  ) {
    final start = startTime.trim();
    final end = endTime.trim();

    if (start.isEmpty && end.isEmpty) {
      return '';
    }

    if (start.isEmpty) {
      return end;
    }

    if (end.isEmpty) {
      return start;
    }

    return '$start–$end';
  }

  // ============================================================
  // SORT TIME SLOTS
  // ============================================================

  List<String> _sortSlots(
    List<String> slots,
  ) {
    final cleaned = slots
        .map(
          (slot) => slot.trim(),
        )
        .where(
          (slot) => slot.isNotEmpty,
        )
        .toSet()
        .toList();

    cleaned.sort(
      (a, b) => _timeSortValue(a)
          .compareTo(
            _timeSortValue(b),
          ),
    );

    return cleaned;
  }

  int _timeSortValue(String slot) {
    final start = slot.split('–').first.trim();

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(start);

    if (match == null) {
      return 999999;
    }

    var hour = int.tryParse(
          match.group(1)!,
        ) ??
        0;

    final minute = int.tryParse(
          match.group(2)!,
        ) ??
        0;

    final period =
        match.group(3)!.toUpperCase();

    if (period == 'AM') {
      if (hour == 12) {
        hour = 0;
      }
    } else {
      if (hour != 12) {
        hour += 12;
      }
    }

    return hour * 60 + minute;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }
}
