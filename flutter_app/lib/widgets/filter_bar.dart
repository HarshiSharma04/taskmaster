import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../providers/providers.dart';
import '../models/task_model.dart';

class FilterBar extends StatelessWidget {
  final TaskFilter currentFilter;
  final void Function(TaskFilter) onFilterChanged;

  const FilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All filter
          _buildChip(
            label: 'All',
            isSelected:
                currentFilter.status == null && currentFilter.priority == null,
            onTap: () => onFilterChanged(
              currentFilter.copyWith(clearStatus: true, clearPriority: true),
            ),
          ),
          const SizedBox(width: 8),
          // Status filters
          ...TaskStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: status.displayName,
                  isSelected: currentFilter.status == status.value,
                  onTap: () => onFilterChanged(
                    currentFilter.copyWith(
                        status: status.value, clearPriority: true),
                  ),
                  color: _statusColor(status),
                ),
              )),
          // Priority filters
          ...TaskPriority.values.map((priority) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: priority.displayName,
                  isSelected: currentFilter.priority == priority.value,
                  onTap: () => onFilterChanged(
                    currentFilter.copyWith(
                        priority: priority.value, clearStatus: true),
                  ),
                  color: _priorityColor(priority),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.terracotta;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : AppColors.cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.sand,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.charcoal.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.statusPending;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.completed:
        return AppColors.statusCompleted;
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
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
