import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/task_model.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isOverdue
                ? AppColors.error.withOpacity(0.3)
                : AppColors.sand,
            width: task.isOverdue ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority color strip
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: _getPriorityColor(),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle checkbox
                      GestureDetector(
                        onTap: onToggle,
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 1, right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppColors.success
                                : Colors.transparent,
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.success
                                  : AppColors.parchment,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 13)
                              : null,
                        ),
                      ),

                      // Title and desc
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? AppColors.charcoal.withOpacity(0.4)
                                    : AppColors.charcoal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (task.description != null &&
                                task.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.charcoal.withOpacity(0.5),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Bottom row: badges + date
                  Row(
                    children: [
                      PriorityBadge(priority: task.priority, compact: true),
                      const SizedBox(width: 6),
                      StatusBadge(status: task.status, compact: true),
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${task.tags.first}${task.tags.length > 1 ? " +${task.tags.length - 1}" : ""}',
                            style: AppTextStyles.caption.copyWith(fontSize: 10),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (task.dueDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: task.isOverdue
                                  ? AppColors.error
                                  : AppColors.charcoal.withOpacity(0.4),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              DateFormat('MMM d').format(task.dueDate!),
                              style: AppTextStyles.caption.copyWith(
                                color: task.isOverdue
                                    ? AppColors.error
                                    : AppColors.charcoal.withOpacity(0.4),
                                fontWeight: task.isOverdue
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }
}
