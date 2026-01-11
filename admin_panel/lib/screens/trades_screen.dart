import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/admin_theme.dart';
import '../widgets/data_table_widget.dart';

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _trades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('trade_requests')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
      
      if (mounted) {
        setState(() {
          _trades = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return AdminTheme.success;
      case 'pending':
        return AdminTheme.warning;
      case 'cancelled':
      case 'rejected':
        return AdminTheme.error;
      case 'accepted':
        return AdminTheme.primaryColor;
      default:
        return AdminTheme.textMuted;
    }
  }

  Future<void> _viewTrade(Map<String, dynamic> trade) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.darkCard,
        title: Text('Trade #${trade['id'].toString().substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: trade.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text('${e.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Text(e.value?.toString() ?? 'null')),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trades', style: Theme.of(context).textTheme.headlineMedium),
                  Text('${_trades.length} trades', style: TextStyle(color: AdminTheme.textMuted)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadTrades,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _trades.isEmpty
                      ? const Center(child: Text('No trades found'))
                      : DataTableWidget(
                          columns: const ['ID', 'Status', 'Created', 'Actions'],
                          rows: _trades.map((trade) => [
                            trade['id']?.toString().substring(0, 8) ?? '',
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(trade['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(trade['status']).withOpacity(0.3)),
                              ),
                              child: Text(
                                trade['status'] ?? 'Unknown',
                                style: TextStyle(
                                  color: _getStatusColor(trade['status']),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            _formatDate(trade['created_at']),
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 18),
                              onPressed: () => _viewTrade(trade),
                              color: AdminTheme.primaryColor,
                            ),
                          ]).toList(),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }
}

