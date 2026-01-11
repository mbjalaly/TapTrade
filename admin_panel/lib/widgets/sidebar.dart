import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/admin_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? toggleTheme;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: isDark ? AdminTheme.darkBorder : AdminTheme.lightBorder),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/appLogo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TapTrade',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(
            color: isDark ? AdminTheme.darkBorder : AdminTheme.lightBorder,
            height: 1,
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.category, 'Categories'),
                _buildNavItem(2, Icons.interests, 'Interests'),
                _buildNavItem(3, Icons.people, 'Users'),
                _buildNavItem(4, Icons.inventory_2, 'Products'),
                _buildNavItem(5, Icons.swap_horiz, 'Trades'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AdminTheme.darkBorder),
                ),
                _buildNavItem(6, Icons.receipt_long, 'Logs'),
              ],
            ),
          ),
          
          // User Info & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AdminTheme.darkBorder : AdminTheme.lightBorder,
                ),
              ),
            ),
            child: Column(
              children: [
                // User Info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AdminTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AdminTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            Supabase.instance.client.auth.currentUser?.email ?? '',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Theme Toggle Button
                if (toggleTheme != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: toggleTheme,
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        size: 18,
                      ),
                      label: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                if (toggleTheme != null) const SizedBox(height: 12),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.error,
                      side: const BorderSide(color: AdminTheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isSelected = selectedIndex == index;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => onItemSelected(index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

