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
  final VoidCallback toggleTheme;
  
  const DashboardScreen({super.key, required this.toggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
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
      // Load counts from Supabase - using same query style as other screens
      int users = 0, products = 0, trades = 0, categories = 0, interests = 0;
      
      try {
        final usersData = await _supabase.from('users').select();
        users = (usersData as List).length;
        print('Users count: $users');
      } catch (e) {
        print('Users table error: $e');
      }
      
      try {
        final productsData = await _supabase.from('products').select();
        products = (productsData as List).length;
        print('Products count: $products');
      } catch (e) {
        print('Products table error: $e');
      }
      
      try {
        final tradesData = await _supabase.from('trade_requests').select();
        trades = (tradesData as List).length;
        print('Trades count: $trades');
      } catch (e) {
        print('Trade requests table error: $e');
      }
      
      try {
        final categoriesData = await _supabase.from('categories').select();
        categories = (categoriesData as List).length;
        print('Categories count: $categories');
      } catch (e) {
        print('Categories table error: $e');
        _error = 'Categories: $e';
      }
      
      try {
        final interestsData = await _supabase.from('interests').select();
        interests = (interestsData as List).length;
        print('Interests count: $interests');
      } catch (e) {
        print('Interests table error: $e');
        _error = '${_error ?? ""} Interests: $e';
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
          
          // Error display
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AdminTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminTheme.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: AdminTheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: AdminTheme.error))),
                ],
              ),
            ),
          
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.brightness == Brightness.dark 
                    ? AdminTheme.darkBorder 
                    : AdminTheme.lightBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    if (isMobile) {
      // Mobile layout with drawer
      return Scaffold(
        key: _scaffoldKey,
        drawer: Sidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context); // Close drawer
            if (index == 0) {
              _loadStats();
            }
          },
          toggleTheme: widget.toggleTheme,
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: Icon(Theme.of(context).brightness == Brightness.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        body: _getScreen(),
      );
    } else {
      // Desktop layout with sidebar
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                if (index == 0) {
                  _loadStats();
                }
              },
              toggleTheme: widget.toggleTheme,
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
}

