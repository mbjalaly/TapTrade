import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AdminTheme.darkSurface),
          columns: columns
              .map((col) => DataColumn(
                    label: Text(
                      col,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          rows: rows
              .map((row) => DataRow(
                    cells: row
                        .map((cell) => DataCell(
                              cell is Widget
                                  ? cell
                                  : Text(
                                      cell.toString(),
                                      style: const TextStyle(
                                        color: AdminTheme.textSecondary,
                                      ),
                                    ),
                            ))
                        .toList(),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

