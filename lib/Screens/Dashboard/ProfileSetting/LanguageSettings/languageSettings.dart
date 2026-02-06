import 'package:flutter/material.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/languageController.dart';
import 'package:taptrade/Services/LocalizationService/localization_service.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Screen for selecting app language
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageController = Get.find<LanguageController>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.selectLanguage,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectLanguage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // English option
            Obx(() => _LanguageOption(
              languageCode: 'en',
              languageName: 'English',
              nativeName: 'English',
              flag: '🇺🇸',
              isSelected: languageController.languageCode == 'en',
              onTap: () => _changeLanguage(context, languageController, 'en'),
            )),
            
            const SizedBox(height: 12),
            
            // Arabic option
            Obx(() => _LanguageOption(
              languageCode: 'ar',
              languageName: l10n.arabic,
              nativeName: 'العربية',
              flag: '🇸🇦',
              isSelected: languageController.languageCode == 'ar',
              onTap: () => _changeLanguage(context, languageController, 'ar'),
            )),
            
            const Spacer(),
            
            // Info text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantColor(context).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineColor(context).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryText(context).withOpacity(0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      languageController.languageCode == 'ar'
                          ? 'تغيير اللغة سيؤثر على جميع شاشات التطبيق'
                          : 'Changing language will affect all app screens',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryText(context).withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _changeLanguage(BuildContext context, LanguageController controller, String languageCode) async {
    await controller.changeLanguage(languageCode);
    // Pop and let the app rebuild with new locale
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

class _LanguageOption extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String nativeName;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryColor.withOpacity(0.1) 
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryColor 
                : AppColors.outlineColor(context).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag emoji
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            
            // Language name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected 
                          ? AppColors.primaryColor 
                          : AppColors.primaryTextColor,
                    ),
                  ),
                  if (languageName != nativeName) ...[
                    const SizedBox(height: 2),
                    Text(
                      languageName,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryText(context).withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Checkmark
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
