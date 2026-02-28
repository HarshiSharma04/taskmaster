import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_config.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.sand.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 44, color: AppColors.charcoal.withOpacity(0.25)),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.charcoal.withOpacity(0.5)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
