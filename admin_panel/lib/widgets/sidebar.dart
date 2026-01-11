import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/admin_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AdminTheme.darkSurface,
        border: Border(
          right: BorderSide(color: AdminTheme.darkBorder),
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
                    'assets/images/mainAppLogo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TapTrade',
                      style: TextStyle(
                        color: AdminTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: AdminTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(color: AdminTheme.darkBorder, height: 1),
          
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
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AdminTheme.darkBorder),
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
                          const Text(
                            'Admin',
                            style: TextStyle(
                              color: AdminTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            Supabase.instance.client.auth.currentUser?.email ?? '',
                            style: const TextStyle(
                              color: AdminTheme.textMuted,
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
              color: isSelected ? AdminTheme.primaryColor.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: AdminTheme.primaryColor.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AdminTheme.primaryColor : AdminTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AdminTheme.primaryColor : AdminTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

