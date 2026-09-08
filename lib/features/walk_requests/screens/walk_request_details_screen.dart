// File:
// lib/features/walk_requests/screens/walk_request_details_screen.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../utils/walk_request_details_helpers.dart';
import '../widgets/walk_request_details_actions.dart';
import '../widgets/walk_request_details_dog.dart';
import '../widgets/walk_request_details_header.dart';
import '../widgets/walk_request_details_information.dart';
import '../widgets/walk_request_details_location.dart';
import '../widgets/walk_request_details_map.dart';
import '../widgets/walk_request_details_owner.dart';
import '../widgets/walk_request_details_summary.dart';
import '../widgets/walk_request_details_walker.dart';

typedef WalkRequestOpenMapsCallback = Future<void> Function(
  LatLng location,
);

class WalkRequestDetailsScreen extends StatelessWidget {
  const WalkRequestDetailsScreen({
    super.key,
    required this.requestId,
    required this.data,
    this.onAssign,
    this.onCancel,
    this.onOpenMaps,
  });

  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback? onAssign;
  final VoidCallback? onCancel;
  final WalkRequestOpenMapsCallback? onOpenMaps;

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final ownerName =
        WalkRequestDetailsHelpers.ownerName(data);

    final ownerId =
        WalkRequestDetailsHelpers.ownerId(data);

    final ownerPhone =
        WalkRequestDetailsHelpers.ownerPhone(data);

    final walkerName =
        WalkRequestDetailsHelpers.walkerName(data);

    final walkerId =
        WalkRequestDetailsHelpers.walkerId(data);

    final walkerPhone =
        WalkRequestDetailsHelpers.walkerPhone(data);

    final dogName =
        WalkRequestDetailsHelpers.dogName(data);

    final dogBreed =
        WalkRequestDetailsHelpers.dogBreed(data);

    final dogPhoto =
        WalkRequestDetailsHelpers.dogPhoto(data);

    final address =
        WalkRequestDetailsHelpers.address(data);

    final searchType =
        WalkRequestDetailsHelpers.searchType(data);

    final radius =
        WalkRequestDetailsHelpers.radius(data);

    final status =
        WalkRequestDetailsHelpers.value(
          data,
          'status',
          fallback: 'pending',
        );

    final createdAt =
        WalkRequestDetailsHelpers.createdAt(data);

    final hasWalker =
        WalkRequestDetailsHelpers.hasWalker(data);

    final isPending =
        WalkRequestDetailsHelpers.isPending(data);

    final ownerLocation =
        WalkRequestDetailsHelpers.ownerLocation(data);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 18,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: dark,
          ),
        ),
        title: const Text(
          'Walk Request Details',
          style: TextStyle(
            color: dark,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: border,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1000;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 32 : 16,
                20,
                isDesktop ? 32 : 16,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1250,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      WalkRequestDetailsHeader(
                        requestId: requestId,
                        status: status,
                        createdAt: createdAt,
                      ),

                      const SizedBox(height: 16),

                      WalkRequestDetailsSummary(
                        requestId: requestId,
                        ownerName: ownerName,
                        dogName: dogName,
                        walkerName: walkerName,
                        status: status,
                        createdAt: createdAt,
                      ),

                      const SizedBox(height: 16),

                      if (isDesktop)
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  WalkRequestDetailsOwner(
                                    ownerName: ownerName,
                                    ownerId: ownerId,
                                    ownerPhone: ownerPhone,
                                  ),

                                  const SizedBox(height: 16),

                                  WalkRequestDetailsDog(
                                    dogName: dogName,
                                    dogBreed: dogBreed,
                                    dogPhoto: dogPhoto,
                                  ),

                                  const SizedBox(height: 16),

                                  WalkRequestDetailsLocation(
                                    address: address,
                                    hasLocation:
                                        ownerLocation != null,
                                    onOpenMaps:
                                        ownerLocation != null &&
                                                onOpenMaps != null
                                            ? () {
                                                onOpenMaps!(
                                                  ownerLocation,
                                                );
                                              }
                                            : null,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  WalkRequestDetailsWalker(
                                    walkerName: walkerName,
                                    walkerId: walkerId,
                                    walkerPhone: walkerPhone,
                                    hasWalker: hasWalker,
                                  ),

                                  const SizedBox(height: 16),

                                  WalkRequestDetailsInformation(
                                    requestId: requestId,
                                    ownerName: ownerName,
                                    dogName: dogName,
                                    walkerName: walkerName,
                                    hasWalker: hasWalker,
                                    status: status,
                                  ),

                                  const SizedBox(height: 16),

                                  if (ownerLocation != null)
                                    WalkRequestDetailsMap(
                                      ownerLocation:
                                          ownerLocation,
                                      walkerId: walkerId,
                                      walkerUid:
                                          WalkRequestDetailsHelpers
                                              .value(
                                        data,
                                        'walkerUid',
                                      ),
                                      walkerName:
                                          walkerName,
                                      onOpenMaps:
                                          ownerLocation != null &&
                                                  onOpenMaps != null
                                              ? () {
                                                  onOpenMaps!(
                                                    ownerLocation,
                                                  );
                                                }
                                              : null,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            WalkRequestDetailsOwner(
                              ownerName: ownerName,
                              ownerId: ownerId,
                              ownerPhone: ownerPhone,
                            ),

                            const SizedBox(height: 16),

                            WalkRequestDetailsDog(
                              dogName: dogName,
                              dogBreed: dogBreed,
                              dogPhoto: dogPhoto,
                            ),

                            const SizedBox(height: 16),

                            WalkRequestDetailsWalker(
                              walkerName: walkerName,
                              walkerId: walkerId,
                              walkerPhone: walkerPhone,
                              hasWalker: hasWalker,
                            ),

                            const SizedBox(height: 16),

                            WalkRequestDetailsLocation(
                              address: address,
                              hasLocation:
                                  ownerLocation != null,
                              onOpenMaps:
                                  ownerLocation != null &&
                                          onOpenMaps != null
                                      ? () {
                                          onOpenMaps!(
                                            ownerLocation,
                                          );
                                        }
                                      : null,
                            ),

                            const SizedBox(height: 16),

                            if (ownerLocation != null)
                              WalkRequestDetailsMap(
                                ownerLocation:
                                    ownerLocation,
                                walkerId: walkerId,
                                walkerUid:
                                    WalkRequestDetailsHelpers.value(
                                  data,
                                  'walkerUid',
                                ),
                                walkerName: walkerName,
                                onOpenMaps:
                                    ownerLocation != null &&
                                            onOpenMaps != null
                                        ? () {
                                            onOpenMaps!(
                                              ownerLocation,
                                            );
                                          }
                                        : null,
                              ),

                            const SizedBox(height: 16),

                            WalkRequestDetailsInformation(
                              requestId: requestId,
                              ownerName: ownerName,
                              dogName: dogName,
                              walkerName: walkerName,
                              hasWalker: hasWalker,
                              status: status,
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      WalkRequestDetailsActions(
                        isPending: isPending,
                        hasWalker: hasWalker,
                        onAssign: onAssign,
                        onCancel: onCancel,
                      ),

                      const SizedBox(height: 24),

                      _BottomReference(
                        requestId: requestId,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottomReference extends StatelessWidget {
  const _BottomReference({
    required this.requestId,
  });

  final String requestId;

  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          color: border,
          height: 1,
        ),
        const SizedBox(height: 14),
        Text(
          'Request ID: $requestId',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: grey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
