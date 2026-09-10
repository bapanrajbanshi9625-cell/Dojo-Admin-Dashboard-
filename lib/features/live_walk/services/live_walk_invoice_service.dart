import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LiveWalkInvoiceService {
  const LiveWalkInvoiceService();

  Future<Uint8List> buildPdf({
    required String sessionId,
    required String requestId,
    required Map<String, dynamic> data,
  }) async {
    final document = pw.Document();

    final distance = _double(data['distanceKm']);

    final durationSeconds =
        _int(data['durationSeconds']) > 0
            ? _int(data['durationSeconds'])
            : _int(data['elapsedSeconds']);

    final duration = _duration(durationSeconds);

    final routePoints = _readRoute(
      data['routeCoordinates'],
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DOJO WALK',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(
                          0xFFFF6B13,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Live Walk Invoice',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColor.fromInt(
                          0xFF667B7D,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _invoiceNumber(sessionId),
                      style: const pw.TextStyle(
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 22),

            _sectionTitle('Walk Information'),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _pdfRow(
                  'Session ID',
                  sessionId,
                ),
                _pdfRow(
                  'Request ID',
                  requestId,
                ),
                _pdfRow(
                  'Status',
                  _string(data['status']).toUpperCase(),
                ),
                _pdfRow(
                  'Source',
                  _firstString(
                    data,
                    ['source'],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            _sectionTitle('Customer & Walker'),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _pdfRow(
                  'Owner',
                  _firstString(
                    data,
                    ['ownerName'],
                  ),
                ),
                _pdfRow(
                  'Owner ID',
                  _firstString(
                    data,
                    ['ownerId'],
                  ),
                ),
                _pdfRow(
                  'Owner Phone',
                  _firstString(
                    data,
                    ['ownerPhone'],
                  ),
                ),
                _pdfRow(
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
                _pdfRow(
                  'Walker ID',
                  _firstString(
                    data,
                    [
                      'walkerId',
                      'id',
                    ],
                  ),
                ),
                _pdfRow(
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

            pw.SizedBox(height: 20),

            _sectionTitle('Dog'),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _pdfRow(
                  'Dog Name',
                  _firstString(
                    data,
                    ['dogName'],
                  ),
                ),
                _pdfRow(
                  'Breed',
                  _firstString(
                    data,
                    ['dogBreed'],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            _sectionTitle('Walk Summary'),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _pdfRow(
                  'Distance',
                  '${distance.toStringAsFixed(2)} km',
                ),
                _pdfRow(
                  'Distance Meters',
                  '${_double(data['distanceMeters']).toStringAsFixed(0)} m',
                ),
                _pdfRow(
                  'Duration',
                  duration,
                ),
                _pdfRow(
                  'Steps',
                  '${_int(data['steps'])}',
                ),
                _pdfRow(
                  'Pee',
                  '${_int(data['peeCount'])}',
                ),
                _pdfRow(
                  'Poop',
                  '${_int(data['poopCount'])}',
                ),
                _pdfRow(
                  'Route Points',
                  '${routePoints.length}',
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            _sectionTitle('GPS'),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _pdfRow(
                  'Latitude',
                  _numberText(
                    data['currentLat'],
                  ),
                ),
                _pdfRow(
                  'Longitude',
                  _numberText(
                    data['currentLng'],
                  ),
                ),
                _pdfRow(
                  'Accuracy',
                  _numberText(
                    data['gpsAccuracy'],
                  ),
                ),
                _pdfRow(
                  'Heading',
                  _numberText(
                    data['gpsHeading'],
                  ),
                ),
                _pdfRow(
                  'Speed',
                  _numberText(
                    data['gpsSpeed'],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            _sectionTitle('Timeline'),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _pdfRow(
                  'Created',
                  _timestamp(data['createdAt']),
                ),
                _pdfRow(
                  'Started',
                  _timestamp(data['startedAt']),
                ),
                _pdfRow(
                  'GPS Updated',
                  _timestamp(data['gpsUpdatedAt']),
                ),
                _pdfRow(
                  'Updated',
                  _timestamp(data['updatedAt']),
                ),
                _pdfRow(
                  'Ended',
                  _timestamp(data['endedAt']),
                ),
                _pdfRow(
                  'Completed',
                  _timestamp(data['completedAt']),
                ),
                _pdfRow(
                  'Cancelled',
                  _timestamp(data['cancelledAt']),
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(
                  0xFFF0F7FF,
                ),
                borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(8),
                ),
              ),
              child: pw.Text(
                'This document is a Dojo Walk session summary generated from the live walk session data.',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromInt(
                    0xFF667B7D,
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  Future<void> downloadPdf({
    required String sessionId,
    required String requestId,
    required Map<String, dynamic> data,
  }) async {
    final bytes = await buildPdf(
      sessionId: sessionId,
      requestId: requestId,
      data: data,
    );

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'dojo_walk_invoice_$sessionId.pdf',
    );
  }

  Future<void> sharePdf({
    required String sessionId,
    required String requestId,
    required Map<String, dynamic> data,
  }) async {
    final bytes = await buildPdf(
      sessionId: sessionId,
      requestId: requestId,
      data: data,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'dojo_walk_invoice_$sessionId.pdf',
    );
  }

  static pw.Text _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: const PdfColor.fromInt(
          0xFF1C3136,
        ),
      ),
    );
  }

  static pw.TableRow _pdfRow(
    String label,
    String value,
  ) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: const PdfColor.fromInt(
            0xFFF5F8F7,
          ),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value.isEmpty ? '—' : value,
            style: const pw.TextStyle(
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }

  static String _invoiceNumber(String sessionId) {
    if (sessionId.length <= 12) {
      return 'INV-$sessionId';
    }

    return 'INV-${sessionId.substring(0, 12)}';
  }

  static String _string(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  static String _firstString(
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

  static double _double(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static int _int(dynamic value) {
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

  static String _numberText(dynamic value) {
    if (value == null) {
      return '—';
    }

    final number = _double(value);

    if (number == 0) {
      return '0';
    }

    return number.toStringAsFixed(6);
  }

  static List<GeoPoint> _readRoute(dynamic value) {
    if (value is! List) {
      return [];
    }

    final result = <GeoPoint>[];

    for (final item in value) {
      if (item is GeoPoint) {
        result.add(item);
        continue;
      }

      if (item is Map) {
        final lat = _double(
          item['lat'] ?? item['latitude'],
        );

        final lng = _double(
          item['lng'] ?? item['longitude'],
        );

        if (lat != 0 || lng != 0) {
          result.add(
            GeoPoint(
              lat,
              lng,
            ),
          );
        }
      }
    }

    return result;
  }

  static String _timestamp(dynamic value) {
    if (value == null) {
      return '—';
    }

    if (value is Timestamp) {
      return _formatDate(
        value.toDate(),
      );
    }

    if (value is DateTime) {
      return _formatDate(value);
    }

    return value.toString();
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();

    String two(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${local.day}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }

  static String _duration(int seconds) {
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
}
