import 'package:flutter/material.dart';

import '../services/live_walk_invoice_service.dart';

class LiveWalkInvoiceScreen extends StatelessWidget {
  final String sessionId;
  final String requestId;
  final Map<String, dynamic> data;

  const LiveWalkInvoiceScreen({
    super.key,
    required this.sessionId,
    required this.requestId,
    required this.data,
  });

  static const _orange = Color(0xFFFF6B13);
  static const _background = Color(0xFFF5F8F7);
  static const _text = Color(0xFF1C3136);
  static const _secondary = Color(0xFF667B7D);

  @override
  Widget build(BuildContext context) {
    final distance = _double(
      data['distanceKm'],
    );

    final durationSeconds =
        _int(data['durationSeconds']) > 0
            ? _int(data['durationSeconds'])
            : _int(data['elapsedSeconds']);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        title: const Text(
          'Invoice',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Download PDF',
            onPressed: () {
              _download(context);
            },
            icon: const Icon(
              Icons.download_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Share Invoice',
            onPressed: () {
              _share(context);
            },
            icon: const Icon(
              Icons.share_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 950,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE0EBE9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: .04,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _InvoiceHeader(
                    sessionId: sessionId,
                    status: _string(
                      data['status'],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Divider(
                    height: 1,
                    color: Color(0xFFE7EFED),
                  ),

                  const SizedBox(height: 20),

                  _SectionTitle(
                    icon: Icons.info_outline_rounded,
                    title: 'Walk Information',
                  ),

                  const SizedBox(height: 10),

                  _ResponsiveInfoGrid(
                    items: [
                      _InfoItem(
                        'Session ID',
                        sessionId,
                      ),
                      _InfoItem(
                        'Request ID',
                        requestId,
                      ),
                      _InfoItem(
                        'Status',
                        _string(
                          data['status'],
                        ).isEmpty
                            ? '—'
                            : _string(
                                data['status'],
                              ).toUpperCase(),
                      ),
                      _InfoItem(
                        'Source',
                        _firstString(
                          data,
                          ['source'],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _SectionTitle(
                    icon: Icons.people_alt_rounded,
                    title: 'Owner & Walker',
                  ),

                  const SizedBox(height: 10),

                  _ResponsiveInfoGrid(
                    items: [
                      _InfoItem(
                        'Owner',
                        _firstString(
                          data,
                          ['ownerName'],
                        ),
                      ),
                      _InfoItem(
                        'Owner ID',
                        _firstString(
                          data,
                          ['ownerId'],
                        ),
                      ),
                      _InfoItem(
                        'Owner Phone',
                        _firstString(
                          data,
                          ['ownerPhone'],
                        ),
                      ),
                      _InfoItem(
                        'Walker',
                        _firstString(
                          data,
                          [
                            'walkerName',
                            'name',
                            'fullName',
                          ],
                        ),
                      ),
                      _InfoItem(
                        'Walker ID',
                        _firstString(
                          data,
                          [
                            'walkerId',
                            'id',
                          ],
                        ),
                      ),
                      _InfoItem(
                        'Walker Phone',
                        _firstString(
                          data,
                          [
                            'walkerPhone',
                            'phone',
                            'phoneNumber',
                            'mobileNumber',
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _SectionTitle(
                    icon: Icons.pets_rounded,
                    title: 'Dog',
                  ),

                  const SizedBox(height: 10),

                  _ResponsiveInfoGrid(
                    items: [
                      _InfoItem(
                        'Dog Name',
                        _firstString(
                          data,
                          ['dogName'],
                        ),
                      ),
                      _InfoItem(
                        'Breed',
                        _firstString(
                          data,
                          ['dogBreed'],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _SectionTitle(
                    icon: Icons.analytics_rounded,
                    title: 'Walk Summary',
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SummaryTile(
                          icon: Icons.route_rounded,
                          label: 'Distance',
                          value:
                              '${distance.toStringAsFixed(2)} km',
                        ),
                        _SummaryTile(
                          icon: Icons.timer_rounded,
                          label: 'Duration',
                          value: _duration(
                            durationSeconds,
                          ),
                        ),
                        _SummaryTile(
                          icon: Icons.directions_walk_rounded,
                          label: 'Steps',
                          value:
                              '${_int(data['steps'])}',
                        ),
                        _SummaryTile(
                          icon: Icons.straighten_rounded,
                          label: 'Meters',
                          value:
                              '${_double(data['distanceMeters']).toStringAsFixed(0)} m',
                        ),
                        _SummaryTile(
                          icon: Icons.water_drop_rounded,
                          label: 'Pee',
                          value:
                              '${_int(data['peeCount'])}',
                        ),
                        _SummaryTile(
                          icon: Icons.circle_rounded,
                          label: 'Poop',
                          value:
                              '${_int(data['poopCount'])}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  _SectionTitle(
                    icon: Icons.gps_fixed_rounded,
                    title: 'GPS',
                  ),

                  const SizedBox(height: 10),

                  _ResponsiveInfoGrid(
                    items: [
                      _InfoItem(
                        'Latitude',
                        _numberText(
                          data['currentLat'],
                        ),
                      ),
                      _InfoItem(
                        'Longitude',
                        _numberText(
                          data['currentLng'],
                        ),
                      ),
                      _InfoItem(
                        'Accuracy',
                        _numberText(
                          data['gpsAccuracy'],
                        ),
                      ),
                      _InfoItem(
                        'Heading',
                        _numberText(
                          data['gpsHeading'],
                        ),
                      ),
                      _InfoItem(
                        'Speed',
                        _numberText(
                          data['gpsSpeed'],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _SectionTitle(
                    icon: Icons.schedule_rounded,
                    title: 'Timeline',
                  ),

                  const SizedBox(height: 10),

                  _ResponsiveInfoGrid(
                    items: [
                      _InfoItem(
                        'Created',
                        _timestamp(
                          data['createdAt'],
                        ),
                      ),
                      _InfoItem(
                        'Started',
                        _timestamp(
                          data['startedAt'],
                        ),
                      ),
                      _InfoItem(
                        'GPS Updated',
                        _timestamp(
                          data['gpsUpdatedAt'],
                        ),
                      ),
                      _InfoItem(
                        'Updated',
                        _timestamp(
                          data['updatedAt'],
                        ),
                      ),
                      _InfoItem(
                        'Ended',
                        _timestamp(
                          data['endedAt'],
                        ),
                      ),
                      _InfoItem(
                        'Completed',
                        _timestamp(
                          data['completedAt'],
                        ),
                      ),
                      _InfoItem(
                        'Cancelled',
                        _timestamp(
                          data['cancelledAt'],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD8EAFB),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Color(0xFF3D82C4),
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'This invoice is generated from the recorded Dojo Walk session data. Pricing is shown only when a pricing field is available in the session data.',
                            style: TextStyle(
                              color: _secondary,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _download(context);
                          },
                          icon: const Icon(
                            Icons.download_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Download PDF',
                          ),
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor: _orange,
                            side: const BorderSide(
                              color: _orange,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _share(context);
                          },
                          icon: const Icon(
                            Icons.share_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Share Invoice',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _download(
    BuildContext context,
  ) async {
    try {
      await const LiveWalkInvoiceService()
          .downloadPdf(
        sessionId: sessionId,
        requestId: requestId,
        data: data,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invoice PDF is ready.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice PDF failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _share(
    BuildContext context,
  ) async {
    try {
      await const LiveWalkInvoiceService()
          .sharePdf(
        sessionId: sessionId,
        requestId: requestId,
        data: data,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invoice shared successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice sharing failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _InvoiceHeader extends StatelessWidget {
  final String sessionId;
  final String status;

  const _InvoiceHeader({
    required this.sessionId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 600;

        final title = Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EA),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFFF6B13),
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DOJO WALK',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Live Walk Invoice',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final statusWidget =
            _StatusBadge(status: status);

        if (compact) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Session: $sessionId',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667B7D),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  statusWidget,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                statusWidget,
                const SizedBox(height: 5),
                SizedBox(
                  width: 250,
                  child: Text(
                    'Session: $sessionId',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF667B7D),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized =
        status.toLowerCase();

    final Color color;

    if (normalized == 'active') {
      color = Colors.green;
    } else if (normalized == 'completed' ||
        normalized == 'complete') {
      color = Colors.blue;
    } else if (normalized.isEmpty) {
      color = Colors.grey;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.isEmpty
                ? 'UNKNOWN'
                : status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6B13),
          size: 19,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1C3136),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ResponsiveInfoGrid extends StatelessWidget {
  final List<_InfoItem> items;

  const _ResponsiveInfoGrid({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth >= 800) {
          columns = 3;
        } else if (constraints.maxWidth >= 500) {
          columns = 2;
        } else {
          columns = 1;
        }

        final width =
            (constraints.maxWidth -
                    ((columns - 1) * 9)) /
                columns;

        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: Container(
                padding:
                    const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF8FAF9),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        color:
                            Color(0xFF91A2A3),
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value.isEmpty
                          ? '—'
                          : item.value,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            Color(0xFF1C3136),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(
    this.label,
    this.value,
  );
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFE1EBE9),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFFFF6B13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color:
                        Color(0xFF91A2A3),
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        Color(0xFF1C3136),
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _string(dynamic value) {
  if (value == null) {
    return '';
  }

  return value.toString().trim();
}

String _firstString(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    if (value != null &&
        value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  return '';
}

double _double(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

int _int(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

String _numberText(dynamic value) {
  if (value == null) {
    return '—';
  }

  final number = _double(value);

  if (number == 0) {
    return '0';
  }

  return number.toStringAsFixed(6);
}

String _timestamp(dynamic value) {
  if (value == null) {
    return '—';
  }

  if (value is DateTime) {
    return _formatDate(value);
  }

  try {
    final timestamp = value;

    final date =
        timestamp.toDate();

    return _formatDate(date);
  } catch (_) {
    return value.toString();
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();

  String two(int value) {
    return value.toString().padLeft(2, '0');
  }

  return '${local.day}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}

String _duration(int seconds) {
  if (seconds <= 0) {
    return '0m';
  }

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  if (minutes > 0) {
    return '${minutes}m ${secs}s';
  }

  return '${secs}s';
}
