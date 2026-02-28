import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../providers/providers.dart';
import '../../models/task_model.dart';
import '../../repositories/task_repository.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/app_snackbar.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;
  const CreateTaskScreen({super.key, this.taskId});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();

  TaskStatus _status = TaskStatus.pending;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  List<String> _tags = [];
  bool _isLoading = false;
  bool _isLoadingTask = false;

  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() => _isLoadingTask = true);
    try {
      final task = await ref.read(taskRepositoryProvider).getTask(widget.taskId!);
      _titleController.text = task.title;
      _descController.text = task.description ?? '';
      _status = task.status;
      _priority = task.priority;
      _dueDate = task.dueDate;
      _tags = List.from(task.tags);
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Failed to load task');
    } finally {
      if (mounted) setState(() => _isLoadingTask = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    bool success;
    if (isEditing) {
      success = await ref.read(taskListProvider.notifier).updateTask(
            widget.taskId!,
            title: _titleController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            status: _status,
            priority: _priority,
            dueDate: _dueDate,
            tags: _tags,
          );
    } else {
      success = await ref.read(taskListProvider.notifier).createTask(
            title: _titleController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            status: _status,
            priority: _priority,
            dueDate: _dueDate,
            tags: _tags,
          );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ref.invalidate(taskStatsProvider);
        AppSnackbar.showSuccess(
            context, isEditing ? 'Task updated!' : 'Task created!');
        context.pop();
      } else {
        AppSnackbar.showError(
            context, isEditing ? 'Failed to update task' : 'Failed to create task');
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.linen,
      appBar: AppBar(
        backgroundColor: AppColors.linen,
        title: Text(isEditing ? 'Edit Task' : 'New Task',
            style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.terracotta),
                    )
                  : Text(
                      isEditing ? 'SAVE' : 'CREATE',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.terracotta),
                    ),
            ),
          ),
        ],
      ),
      body: _isLoadingTask
          ? Center(
              child: CircularProgressIndicator(color: AppColors.terracotta))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Task Details',
                      [
                        CustomTextField(
                          controller: _titleController,
                          label: 'Title',
                          hint: 'What needs to be done?',
                          maxLines: 1,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _descController,
                          label: 'Description (optional)',
                          hint: 'Add more details...',
                          maxLines: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Status & Priority',
                      [
                        _buildStatusSelector(),
                        const SizedBox(height: 16),
                        _buildPrioritySelector(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Due Date',
                      [_buildDueDatePicker()],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Tags',
                      [_buildTagsSection()],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.charcoal.withOpacity(0.5),
            fontSize: 11,
          )),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600, color: AppColors.charcoal.withOpacity(0.7))),
        const SizedBox(height: 8),
        Row(
          children: TaskStatus.values.map((status) {
            final isSelected = _status == status;
            Color bgColor;
            switch (status) {
              case TaskStatus.pending: bgColor = AppColors.statusPending; break;
              case TaskStatus.inProgress: bgColor = AppColors.statusInProgress; break;
              case TaskStatus.completed: bgColor = AppColors.statusCompleted; break;
            }
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _status = status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? bgColor
                        : bgColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? bgColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      status.displayName,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : bgColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal.withOpacity(0.7),
        )),
        const SizedBox(height: 8),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = _priority == priority;
            Color priorityColor;
            switch (priority) {
              case TaskPriority.low: priorityColor = AppColors.priorityLow; break;
              case TaskPriority.medium: priorityColor = AppColors.priorityMedium; break;
              case TaskPriority.high: priorityColor = AppColors.priorityHigh; break;
              case TaskPriority.urgent: priorityColor = AppColors.priorityUrgent; break;
            }
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priority = priority),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? priorityColor
                        : priorityColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? priorityColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      priority.displayName,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : priorityColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.terracotta,
                  onPrimary: Colors.white,
                  surface: AppColors.cream,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) setState(() => _dueDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.sand.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _dueDate != null ? AppColors.terracotta : AppColors.parchment,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: _dueDate != null ? AppColors.terracotta : AppColors.charcoal.withOpacity(0.5),
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              _dueDate != null
                  ? DateFormat('EEEE, MMMM d, yyyy').format(_dueDate!)
                  : 'Set due date (optional)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _dueDate != null
                    ? AppColors.charcoal
                    : AppColors.charcoal.withOpacity(0.4),
              ),
            ),
            const Spacer(),
            if (_dueDate != null)
              GestureDetector(
                onTap: () => setState(() => _dueDate = null),
                child: Icon(Icons.close_rounded,
                    color: AppColors.charcoal.withOpacity(0.5), size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add a tag...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.charcoal.withOpacity(0.4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.parchment),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.parchment),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppColors.terracotta, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addTag,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _tags
                .map((tag) => Chip(
                      label: Text(tag, style: AppTextStyles.caption),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                      backgroundColor: AppColors.terracotta.withOpacity(0.12),
                      deleteIconColor: AppColors.terracotta,
                      side: BorderSide(
                          color: AppColors.terracotta.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
