import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.terracotta.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text('TaskMaster', style: AppTextStyles.displayLarge)
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Organize your world',
              style: AppTextStyles.bodyMedium,
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms),
            const SizedBox(height: 40),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.terracotta,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }
}
