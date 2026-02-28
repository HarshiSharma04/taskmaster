import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/task_model.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityBadge({super.key, required this.priority, this.compact = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (priority) {
      case TaskPriority.low:
        color = AppColors.priorityLow;
        icon = Icons.arrow_downward_rounded;
        break;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
        icon = Icons.remove_rounded;
        break;
      case TaskPriority.high:
        color = AppColors.priorityHigh;
        icon = Icons.arrow_upward_rounded;
        break;
      case TaskPriority.urgent:
        color = AppColors.priorityUrgent;
        icon = Icons.keyboard_double_arrow_up_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          SizedBox(width: compact ? 3 : 4),
          Text(
            priority.displayName,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
