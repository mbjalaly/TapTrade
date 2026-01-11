import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/admin_theme.dart';
import '../widgets/data_table_widget.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _interests = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final interestsResponse = await _supabase
          .from('interests')
          .select('*, categories(name)')
          .order('created_at', ascending: false);
      
      final categoriesResponse = await _supabase
          .from('categories')
          .select()
          .order('name');
      
      if (mounted) {
        setState(() {
          _interests = List<Map<String, dynamic>>.from(interestsResponse);
          _categories = List<Map<String, dynamic>>.from(categoriesResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addInterest() async {
    final nameController = TextEditingController();
    String? selectedCategoryId;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AdminTheme.darkCard,
          title: const Text('Add Interest'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Interest Name',
                  hintText: 'e.g., Smartphones',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                dropdownColor: AdminTheme.darkCard,
                items: _categories.map((cat) => DropdownMenuItem<String>(
                  value: cat['id'].toString(),
                  child: Text(cat['name'] ?? ''),
                )).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedCategoryId = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        final Map<String, dynamic> insertData = {
          'name': nameController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        };
        // Add category_id if selected (handle both int and UUID types)
        if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
          insertData['category_id'] = selectedCategoryId!;
        }
        await _supabase.from('interests').insert(insertData);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Interest added'), backgroundColor: AdminTheme.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  Future<void> _deleteInterest(Map<String, dynamic> interest) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.darkCard,
        title: const Text('Delete Interest'),
        content: Text('Are you sure you want to delete "${interest['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _supabase.from('interests').delete().eq('id', interest['id']);
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
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
                  Text('Interests', style: Theme.of(context).textTheme.headlineMedium),
                  Text('${_interests.length} interests', style: TextStyle(color: AdminTheme.textMuted)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addInterest,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Interest'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _interests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.interests, size: 64, color: AdminTheme.textMuted),
                              const SizedBox(height: 16),
                              const Text('No interests yet'),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: _addInterest, child: const Text('Add Interest')),
                            ],
                          ),
                        )
                      : DataTableWidget(
                          columns: const ['ID', 'Name', 'Category', 'Actions'],
                          rows: _interests.map((item) => [
                            item['id'].toString(),
                            item['name'] ?? '',
                            item['categories']?['name'] ?? '-',
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () => _deleteInterest(item),
                              color: AdminTheme.error,
                            ),
                          ]).toList(),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

