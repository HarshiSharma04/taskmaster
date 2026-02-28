import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../providers/providers.dart';
import '../../models/task_model.dart';
import '../../repositories/task_repository.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_snackbar.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  TaskModel? _task;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      final task = await ref.read(taskRepositoryProvider).getTask(widget.taskId);
      setState(() {
        _task = task;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('TaskException: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.linen,
      appBar: AppBar(
        backgroundColor: AppColors.linen,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.charcoal),
              onPressed: () => context.push('/tasks/${widget.taskId}/edit'),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: _deleteTask,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.terracotta))
          : _error != null
              ? Center(
                  child: Text(_error!, style: AppTextStyles.bodyMedium))
              : _buildBody(),
      bottomNavigationBar: _task != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _toggleTask,
                    icon: Icon(
                      _task!.status == TaskStatus.completed
                          ? Icons.refresh_rounded
                          : Icons.check_circle_outline_rounded,
                    ),
                    label: Text(
                      _task!.status == TaskStatus.completed
                          ? 'Mark as Pending'
                          : 'Mark as Complete',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _task!.status == TaskStatus.completed
                          ? AppColors.slate
                          : AppColors.success,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    final task = _task!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.displayMedium,
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(status: task.status),
            ],
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          const SizedBox(height: 12),

          // Priority and due date
          Row(
            children: [
              PriorityBadge(priority: task.priority),
              if (task.dueDate != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isOverdue
                        ? AppColors.error.withOpacity(0.12)
                        : AppColors.sand,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: task.isOverdue
                          ? AppColors.error.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: task.isOverdue
                            ? AppColors.error
                            : AppColors.charcoal.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(task.dueDate!),
                        style: AppTextStyles.caption.copyWith(
                          color: task.isOverdue
                              ? AppColors.error
                              : AppColors.charcoal.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          if (task.description != null && task.description!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESCRIPTION',
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(task.description!, style: AppTextStyles.bodyLarge),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
          ],

          // Tags
          if (task.tags.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TAGS',
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: task.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.terracotta.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.terracotta.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.terracotta,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
          ],

          // Metadata
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.sand),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIMELINE',
                  style: AppTextStyles.caption.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMetaRow(
                  Icons.add_circle_outline_rounded,
                  'Created',
                  DateFormat('MMMM d, yyyy • h:mm a').format(task.createdAt),
                ),
                const SizedBox(height: 8),
                _buildMetaRow(
                  Icons.update_rounded,
                  'Updated',
                  DateFormat('MMMM d, yyyy • h:mm a').format(task.updatedAt),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.charcoal.withOpacity(0.4)),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal.withOpacity(0.5),
        )),
        Expanded(
          child: Text(value, style: AppTextStyles.caption.copyWith(
            color: AppColors.charcoal.withOpacity(0.8),
          )),
        ),
      ],
    );
  }

  Future<void> _toggleTask() async {
    final success =
        await ref.read(taskListProvider.notifier).toggleTask(widget.taskId);
    if (success) {
      await _loadTask();
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Task updated');
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Task', style: AppTextStyles.headingMedium),
        content: Text('Are you sure? This cannot be undone.',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success =
          await ref.read(taskListProvider.notifier).deleteTask(widget.taskId);
      if (mounted) {
        if (success) {
          ref.invalidate(taskStatsProvider);
          context.pop();
        } else {
          AppSnackbar.showError(context, 'Failed to delete task');
        }
      }
    }
  }
}
