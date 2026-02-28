import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/task_model.dart';

class StatsCard extends StatelessWidget {
  final TaskStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.terracotta, AppColors.burntSienna],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracotta.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.completionRate}%',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      'Completion Rate',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Circular progress
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: stats.completionRate / 100,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                    Center(
                      child: Text(
                        '${stats.completed}',
                        style: AppTextStyles.headingMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(Icons.pending_outlined, '${stats.pending}', 'Pending'),
              _divider(),
              _statItem(Icons.sync_rounded, '${stats.inProgress}', 'Active'),
              _divider(),
              _statItem(
                  Icons.warning_amber_rounded, '${stats.overdue}', 'Overdue'),
              _divider(),
              _statItem(Icons.local_fire_department_rounded, '${stats.urgent}',
                  'Urgent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
