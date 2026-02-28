import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/task_model.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case TaskStatus.pending:
        color = AppColors.statusPending;
        icon = Icons.hourglass_empty_rounded;
        break;
      case TaskStatus.inProgress:
        color = AppColors.statusInProgress;
        icon = Icons.sync_rounded;
        break;
      case TaskStatus.completed:
        color = AppColors.statusCompleted;
        icon = Icons.check_circle_outline_rounded;
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
            status.displayName,
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
