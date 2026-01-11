import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/admin_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/stats_card.dart';
import 'categories_screen.dart';
import 'interests_screen.dart';
import 'users_screen.dart';
import 'products_screen.dart';
import 'trades_screen.dart';
import 'logs_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _supabase = Supabase.instance.client;
  
  // Stats
  int _totalUsers = 0;
  int _totalProducts = 0;
  int _totalTrades = 0;
  int _totalCategories = 0;
  int _totalInterests = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  String? _error;

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Load counts from Supabase - handle each separately
      int users = 0, products = 0, trades = 0, categories = 0;
      
      try {
        final usersCount = await _supabase.from('users').select('id').count();
        users = usersCount.count;
      } catch (e) {
        print('Users table error: $e');
      }
      
      try {
        final productsCount = await _supabase.from('products').select('id').count();
        products = productsCount.count;
      } catch (e) {
        print('Products table error: $e');
      }
      
      try {
        final tradesCount = await _supabase.from('trades').select('id').count();
        trades = tradesCount.count;
      } catch (e) {
        print('Trades table error: $e');
      }
      
      try {
        final categoriesCount = await _supabase.from('categories').select('id').count();
        categories = categoriesCount.count;
      } catch (e) {
        print('Categories table error: $e');
      }
      
      int interests = 0;
      try {
        final interestsCount = await _supabase.from('interests').select('id').count();
        interests = interestsCount.count;
      } catch (e) {
        print('Interests table error: $e');
      }
      
      if (mounted) {
        setState(() {
          _totalUsers = users;
          _totalProducts = products;
          _totalTrades = trades;
          _totalCategories = categories;
          _totalInterests = interests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const CategoriesScreen();
      case 2:
        return const InterestsScreen();
      case 3:
        return const UsersScreen();
      case 4:
        return const ProductsScreen();
      case 5:
        return const TradesScreen();
      case 6:
        return const LogsScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
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
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, Admin',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AdminTheme.textMuted,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _loadStats,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Stats Grid
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 4;
                if (constraints.maxWidth < 1200) crossAxisCount = 2;
                if (constraints.maxWidth < 600) crossAxisCount = 1;
                
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.8,
                  children: [
                    StatsCard(
                      title: 'Total Users',
                      value: _totalUsers.toString(),
                      icon: Icons.people,
                      color: AdminTheme.primaryColor,
                      onTap: () => setState(() => _selectedIndex = 3),
                    ),
                    StatsCard(
                      title: 'Products',
                      value: _totalProducts.toString(),
                      icon: Icons.inventory_2,
                      color: AdminTheme.secondaryColor,
                      onTap: () => setState(() => _selectedIndex = 4),
                    ),
                    StatsCard(
                      title: 'Trades',
                      value: _totalTrades.toString(),
                      icon: Icons.swap_horiz,
                      color: AdminTheme.accentColor,
                      onTap: () => setState(() => _selectedIndex = 5),
                    ),
                    StatsCard(
                      title: 'Categories',
                      value: _totalCategories.toString(),
                      icon: Icons.category,
                      color: AdminTheme.success,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    StatsCard(
                      title: 'Interests',
                      value: _totalInterests.toString(),
                      icon: Icons.interests,
                      color: Colors.purple,
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                  ],
                );
              },
            ),
          
          const SizedBox(height: 32),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAction(
                'Add Category',
                Icons.add_circle_outline,
                () => setState(() => _selectedIndex = 1),
              ),
              _buildQuickAction(
                'Add Interest',
                Icons.interests,
                () => setState(() => _selectedIndex = 2),
              ),
              _buildQuickAction(
                'View Users',
                Icons.people_outline,
                () => setState(() => _selectedIndex = 3),
              ),
              _buildQuickAction(
                'View Logs',
                Icons.receipt_long,
                () => setState(() => _selectedIndex = 6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AdminTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AdminTheme.primaryColor),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AdminTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
              // Refresh stats when returning to dashboard
              if (index == 0) {
                _loadStats();
              }
            },
          ),
          
          // Main Content
          Expanded(
            child: _getScreen(),
          ),
        ],
      ),
    );
  }
}

