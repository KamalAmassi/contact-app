import 'package:contact_app/core/constant/AppSize.dart';
import 'package:contact_app/core/theme/AppColors.dart';
import 'package:flutter/material.dart';

class ContactsEmptyView extends StatelessWidget {
  final bool isSearch;
  const ContactsEmptyView({super.key, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: isSearch ? Icons.search_off_rounded : Icons.contacts_outlined,
      title: isSearch ? 'ما في نتائج' : 'لا توجد جهات اتصال',
      subtitle: isSearch
          ? 'جرب البحث بكلمة ثانية'
          : 'اضغط على "إضافة جهة" لإضافة أول جهة اتصال',
    );
  }
}

class ContactsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ContactsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.danger,
      title: 'صار خطأ',
      subtitle: message,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('إعادة المحاولة'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? action;

  const _StateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.primary,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1),
              ),
              child: Icon(icon, size: 44, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}