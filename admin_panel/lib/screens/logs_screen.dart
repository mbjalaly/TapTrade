import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/admin_theme.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  String _selectedLevel = 'all';
  bool _autoRefresh = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      // Try to load from 'logs' table, or 'activity_logs', or 'audit_logs'
      List<Map<String, dynamic>> logs = [];
      
      for (final tableName in ['logs', 'activity_logs', 'audit_logs', 'system_logs']) {
        try {
          final response = await _supabase
              .from(tableName)
              .select()
              .order('created_at', ascending: false)
              .limit(200);
          
          logs = List<Map<String, dynamic>>.from(response);
          if (logs.isNotEmpty) break;
        } catch (e) {
          // Table doesn't exist, try next
          continue;
        }
      }
      
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    if (_selectedLevel == 'all') return _logs;
    return _logs.where((log) {
      final level = (log['level'] ?? log['type'] ?? '').toString().toLowerCase();
      return level == _selectedLevel;
    }).toList();
  }

  Color _getLevelColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'error':
        return AdminTheme.error;
      case 'warning':
      case 'warn':
        return AdminTheme.warning;
      case 'info':
        return AdminTheme.info;
      case 'success':
        return AdminTheme.success;
      case 'debug':
        return AdminTheme.accentColor;
      default:
        return AdminTheme.textMuted;
    }
  }

  IconData _getLevelIcon(String? level) {
    switch (level?.toLowerCase()) {
      case 'error':
        return Icons.error;
      case 'warning':
      case 'warn':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'success':
        return Icons.check_circle;
      case 'debug':
        return Icons.bug_report;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Logs', style: Theme.of(context).textTheme.headlineMedium),
                  Text('${_filteredLogs.length} log entries', style: TextStyle(color: AdminTheme.textMuted)),
                ],
              ),
              Row(
                children: [
                  // Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AdminTheme.darkCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.darkBorder),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedLevel,
                      underline: const SizedBox(),
                      dropdownColor: AdminTheme.darkCard,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Levels')),
                        DropdownMenuItem(value: 'error', child: Text('Error')),
                        DropdownMenuItem(value: 'warning', child: Text('Warning')),
                        DropdownMenuItem(value: 'info', child: Text('Info')),
                        DropdownMenuItem(value: 'debug', child: Text('Debug')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedLevel = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _loadLogs,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Logs List
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _logs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, size: 64, color: AdminTheme.textMuted),
                              const SizedBox(height: 16),
                              const Text('No logs found'),
                              const SizedBox(height: 8),
                              Text(
                                'Create a "logs" table in Supabase to track activity',
                                style: TextStyle(color: AdminTheme.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () => _showCreateTableInfo(),
                                child: const Text('How to create logs table'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            final level = log['level'] ?? log['type'] ?? 'info';
                            final message = log['message'] ?? log['action'] ?? log['description'] ?? '';
                            final timestamp = log['created_at'] ?? log['timestamp'];
                            
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AdminTheme.darkBorder.withOpacity(0.5)),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Level Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getLevelColor(level).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getLevelIcon(level),
                                      color: _getLevelColor(level),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getLevelColor(level).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                level.toString().toUpperCase(),
                                                style: TextStyle(
                                                  color: _getLevelColor(level),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDateTime(timestamp),
                                              style: TextStyle(
                                                color: AdminTheme.textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          message.toString(),
                                          style: const TextStyle(color: AdminTheme.textSecondary),
                                        ),
                                        if (log['user_id'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'User: ${log['user_id'].toString().substring(0, 8)}...',
                                            style: TextStyle(color: AdminTheme.textMuted, fontSize: 11),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTableInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.darkCard,
        title: const Text('Create Logs Table'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Run this SQL in Supabase SQL Editor:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminTheme.darkBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  '''CREATE TABLE logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  level VARCHAR(20) DEFAULT 'info',
  message TEXT,
  user_id UUID REFERENCES auth.users(id),
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to insert
CREATE POLICY "Allow insert" ON logs FOR INSERT 
  TO authenticated WITH CHECK (true);

-- Allow admins to read all
CREATE POLICY "Allow read" ON logs FOR SELECT 
  TO authenticated USING (true);''',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

