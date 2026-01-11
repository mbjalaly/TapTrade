import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/admin_theme.dart';
import '../widgets/data_table_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('[ProductsScreen] Loading products...');
      
      // Simplified query without join to avoid potential issues
      final response = await _supabase
          .from('products')
          .select('id, title, user_id, created_at, status, min_price, max_price')
          .order('created_at', ascending: false)
          .limit(100);
      
      print('[ProductsScreen] Response received: ${response.length} items');
      
      if (mounted) {
        setState(() {
          try {
            _products = List<Map<String, dynamic>>.from(response ?? []);
            print('[ProductsScreen] Parsed ${_products.length} products');
          } catch (e) {
            print('[ProductsScreen] Error parsing products: $e');
            _products = [];
            _errorMessage = 'Error parsing products: $e';
          }
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('[ProductsScreen] Error loading products: $e');
      print('[ProductsScreen] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products.where((p) {
      try {
        final title = (p['title'] ?? p['name'] ?? '').toString().toLowerCase();
        final id = (p['id'] ?? '').toString().toLowerCase();
        return title.contains(query) || id.contains(query);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Future<void> _viewProduct(Map<String, dynamic> product) async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.darkCard,
        title: Text(product['name'] ?? product['title'] ?? 'Product'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product['image'] != null || product['image_url'] != null)
                  Builder(
                    builder: (context) {
                      final imageUrl = product['image']?.toString() ?? product['image_url']?.toString() ?? '';
                      
                      // Check if it's a base64 data URI
                      if (imageUrl.startsWith('data:image')) {
                        try {
                          final base64String = imageUrl.split(',')[1];
                          final imageBytes = base64Decode(base64String);
                          return Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AdminTheme.darkSurface,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 64),
                              ),
                            ),
                          );
                        } catch (e) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AdminTheme.darkSurface,
                            ),
                            child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
                          );
                        }
                      } else if (imageUrl.isNotEmpty) {
                        // Regular network image
                        return Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AdminTheme.darkSurface,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 64),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ...product.entries.where((e) => e.key != 'image' && e.key != 'image_url' && e.key != 'images').map((e) {
                  // Safely convert value to string
                  String valueStr = 'null';
                  try {
                    final value = e.value;
                    if (value == null) {
                      valueStr = 'null';
                    } else if (value is String || value is num || value is bool) {
                      valueStr = value.toString();
                    } else if (value is Map) {
                      valueStr = '{${value.keys.join(', ')}}';
                    } else if (value is List) {
                      valueStr = '[${value.length} items]';
                    } else {
                      valueStr = value.toString();
                    }
                  } catch (ex) {
                    valueStr = '[Error displaying value]';
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text('${e.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Text(valueStr)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
    } catch (e, stackTrace) {
      print('Error viewing product: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error displaying product: ${e.toString()}'),
            backgroundColor: AdminTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.darkCard,
        title: const Text('Delete Product'),
        content: Text('Delete "${product['name'] ?? product['title']}"?'),
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
        await _supabase.from('products').delete().eq('id', product['id']);
        _loadProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.error),
          );
        }
      }
    }
  }

  String? _errorMessage;
  
  @override
  Widget build(BuildContext context) {
    // Catch any build errors
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AdminTheme.error),
              const SizedBox(height: 16),
              Text('Error: $_errorMessage', style: const TextStyle(color: AdminTheme.error)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _errorMessage = null);
                  _loadProducts();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
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
                  Text('Products', style: Theme.of(context).textTheme.headlineMedium),
                  Text('${_products.length} products', style: const TextStyle(color: AdminTheme.textMuted)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(hintText: 'Search products...', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : _buildDataTable(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataTable() {
    try {
      print('[ProductsScreen] Building data table with ${_filteredProducts.length} products');
      
      final List<List<dynamic>> rows = [];
      
      for (int i = 0; i < _filteredProducts.length; i++) {
        try {
          final p = _filteredProducts[i];
          
          // Safely extract id
          final id = p['id'];
          final idStr = id?.toString() ?? '-';
          
          // Safely extract name/title
          final nameStr = p['title']?.toString() ?? p['name']?.toString() ?? '-';
          
          // Status
          final statusStr = p['status']?.toString() ?? '-';
          
          // Price
          final minPrice = p['min_price']?.toString() ?? '0';
          final maxPrice = p['max_price']?.toString() ?? '0';
          final priceStr = '$minPrice - $maxPrice';
          
          rows.add([
            idStr,
            nameStr,
            statusStr,
            priceStr,
            _formatDate(p['created_at']),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 18),
                  onPressed: () => _viewProduct(p),
                  color: AdminTheme.primaryColor,
                  tooltip: 'View',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () => _deleteProduct(p),
                  color: AdminTheme.error,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ]);
        } catch (rowError) {
          print('[ProductsScreen] Error processing row $i: $rowError');
          rows.add(['-', 'Error loading', '-', '-', '-', const SizedBox()]);
        }
      }
      
      print('[ProductsScreen] Built ${rows.length} rows');
      
      return DataTableWidget(
        columns: const ['ID', 'Title', 'Status', 'Price', 'Created', 'Actions'],
        rows: rows,
      );
    } catch (e, stackTrace) {
      print('[ProductsScreen] Error building data table: $e');
      print('[ProductsScreen] Stack trace: $stackTrace');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AdminTheme.error),
            const SizedBox(height: 8),
            Text('Error rendering products: $e', 
              style: const TextStyle(color: AdminTheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '-';
    try {
      final dateStr = dateValue.toString();
      if (dateStr.isEmpty) return '-';
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '-';
    }
  }
}

