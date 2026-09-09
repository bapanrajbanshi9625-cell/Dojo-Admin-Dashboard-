import '../models/walk_request_model.dart';

List<WalkRequestModel> filterWalkRequests(
  List<WalkRequestModel> requests,
  String selectedFilter,
  String searchQuery,
) {
  final query = searchQuery.trim().toLowerCase();
  final filter = selectedFilter.trim().toLowerCase();

  return requests.where((request) {
    // ========================================================
    // SEARCH
    // ========================================================

    final searchMatch =
        query.isEmpty ||
        request.requestId
            .toLowerCase()
            .contains(query) ||
        request.ownerId
            .toLowerCase()
            .contains(query) ||
        request.ownerName
            .toLowerCase()
            .contains(query) ||
        request.walkerId
            .toLowerCase()
            .contains(query) ||
        (request.walkerName ?? '')
            .toLowerCase()
            .contains(query) ||
        request.status
            .toLowerCase()
            .contains(query) ||
        request.address
            .toLowerCase()
            .contains(query);

    // ========================================================
    // STATUS FILTER
    // ========================================================

    final status =
        request.status.trim().toLowerCase();

    bool filterMatch;

    switch (filter) {
      case '':
      case 'all':
        filterMatch = true;
        break;

      // ------------------------------------------------------
      // PENDING
      // ------------------------------------------------------

      case 'pending':
      case 'searching':
      case 'requested':
        filterMatch =
            status == 'pending' ||
            status == 'searching' ||
            status == 'requested';
        break;

      // ------------------------------------------------------
      // ACCEPTED
      // ------------------------------------------------------

      case 'accepted':
      case 'assigned':
        filterMatch =
            status == 'accepted' ||
            status == 'assigned';
        break;

      // ------------------------------------------------------
      // ACTIVE
      // ------------------------------------------------------

      case 'active':
      case 'started':
      case 'in_progress':
      case 'in-progress':
      case 'live':
        filterMatch =
            status == 'active' ||
            status == 'started' ||
            status == 'in_progress' ||
            status == 'in-progress' ||
            status == 'live';
        break;

      // ------------------------------------------------------
      // COMPLETED
      // ------------------------------------------------------

      case 'completed':
      case 'complete':
        filterMatch =
            status == 'completed' ||
            status == 'complete';
        break;

      // ------------------------------------------------------
      // CANCELLED
      // ------------------------------------------------------

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        filterMatch =
            status == 'cancelled' ||
            status == 'canceled' ||
            status == 'rejected';
        break;

      // ------------------------------------------------------
      // UNKNOWN FILTER
      // ------------------------------------------------------

      default:
        filterMatch = status == filter;
        break;
    }

    return searchMatch && filterMatch;
  }).toList();
}
