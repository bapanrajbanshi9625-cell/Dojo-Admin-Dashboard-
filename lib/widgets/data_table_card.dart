import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class DataTableCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> columns;
  final List<List<String>> rows;
  final VoidCallback? onViewAll;
  final Function(List<String>)? onRowTap;

  const DataTableCard({
    super.key,
    required this.title,
    required this.icon,
    required this.columns,
    required this.rows,
    this.onViewAll,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const Divider(
            height: 1,
            color: dojoBorder,
          ),
          if (rows.isEmpty)
            _empty()
          else
            _table(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEE9),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: dojoOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: dojoBlack,
              ),
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: dojoOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _table() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowHeight: 46,
              dataRowMinHeight: 54,
              dataRowMaxHeight: 62,
              horizontalMargin: 16,
              columnSpacing: 28,
              headingTextStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: dojoGrey,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 11,
                color: dojoBlack,
                fontWeight: FontWeight.w600,
              ),
              columns: columns.map((column) {
                return DataColumn(
                  label: Text(column),
                );
              }).toList(),
              rows: rows.map((row) {
                return DataRow(
                  onSelectChanged: onRowTap == null
                      ? null
                      : (_) => onRowTap!(row),
                  cells: List.generate(
                    columns.length,
                    (index) {
                      final value =
                          index < row.length
                              ? row[index]
                              : '';

                      return DataCell(
                        _cell(
                          value,
                          index,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _cell(
    String value,
    int columnIndex,
  ) {
    // Status columns get small colored chips.
    final lower = value.toLowerCase();

    if (lower == 'active' ||
        lower == 'completed' ||
        lower == 'paid' ||
        lower == 'approved' ||
        lower == 'online') {
      return _statusChip(
        value,
        dojoGreen,
      );
    }

    if (lower == 'pending' ||
        lower == 'waiting') {
      return _statusChip(
        value,
        dojoOrange,
      );
    }

    if (lower == 'cancelled' ||
        lower == 'rejected' ||
        lower == 'offline') {
      return _statusChip(
        value,
        dojoRed,
      );
    }

    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _statusChip(
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _empty() {
    return const SizedBox(
      height: 190,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_rows_outlined,
              size: 42,
              color: dojoGrey,
            ),
            SizedBox(height: 10),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: dojoBlack,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Data will appear here when available.',
              style: TextStyle(
                fontSize: 11,
                color: dojoGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
