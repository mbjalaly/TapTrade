import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Reusable settings list item widget
/// Extracted from ProfileSetting to be shared across app
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDestructive
        ? Colors.red
        : Theme.of(context).colorScheme.onSurface;
    final Color iconColor = isDestructive
        ? Colors.red
        : AppColors.primaryText(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.surfaceVariantColor(context),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.greyText(context),
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).dividerColor,
          ),
    );
  }
}

/// Settings item with a trailing Switch widget
/// Used for toggleable preferences
class SwitchSettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDisabled;
  final Widget? badge;

  const SwitchSettingsItem({
    Key? key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.surfaceVariantColor(context),
          child: Icon(icon, color: AppColors.primaryText(context), size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: 8),
              badge!,
            ],
          ],
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.greyText(context),
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: isDisabled ? null : onChanged,
          activeTrackColor: AppColors.primaryColor,
        ),
      ),
    );
  }
}

/// Badge widget for "Soon", "Beta", "New" labels
class SettingsBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const SettingsBadge({
    Key? key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.orange.shade800,
        ),
      ),
    );
  }
}

/// Section header for settings groups
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const SettingsSectionHeader({
    Key? key,
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(0, 24, 0, 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.greyText(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
