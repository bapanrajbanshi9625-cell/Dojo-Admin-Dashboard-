import '../models/walk_request_model.dart';

List<WalkRequestModel> filterWalkRequests(
  List<WalkRequestModel> requests,
  String selectedFilter,
  String searchQuery,
) {
  final query = searchQuery.trim().toLowerCase();

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

    final filterMatch =
        selectedFilter == 'All' ||
        request.status.toLowerCase() ==
            selectedFilter.toLowerCase();

    return searchMatch && filterMatch;
  }).toList();
}
