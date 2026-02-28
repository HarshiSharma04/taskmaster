import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../config/app_config.dart';
import '../../providers/providers.dart';
import '../../models/task_model.dart';
import '../../widgets/task_card.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/task_shimmer.dart';

class TaskDashboardScreen extends ConsumerStatefulWidget {
  const TaskDashboardScreen({super.key});

  @override
  ConsumerState<TaskDashboardScreen> createState() =>
      _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends ConsumerState<TaskDashboardScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListProvider.notifier).loadTasks();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(taskListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);
    final authState = ref.watch(authProvider);
    final filter = ref.watch(taskFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.linen,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(authState.user?.username ?? 'User'),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Stats Row
                _buildStatsSection(),
                // Filter bar
                FilterBar(
                  currentFilter: filter,
                  onFilterChanged: (newFilter) {
                    ref.read(taskFilterProvider.notifier).state = newFilter;
                    ref.read(taskListProvider.notifier).loadTasks();
                  },
                ),
              ],
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () => ref.read(taskListProvider.notifier).loadTasks(),
          color: AppColors.terracotta,
          backgroundColor: AppColors.cream,
          child: _buildTaskList(taskState),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text('New Task', style: AppTextStyles.button),
        backgroundColor: AppColors.terracotta,
      ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildSliverAppBar(String username) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: AppColors.linen,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: _showSearch
            ? Padding(
                padding: const EdgeInsets.only(right: 80),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (v) {
                    ref.read(taskFilterProvider.notifier).state =
                        ref.read(taskFilterProvider).copyWith(search: v);
                    ref.read(taskListProvider.notifier).loadTasks();
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good day,',
                    style: AppTextStyles.caption.copyWith(fontSize: 13),
                  ),
                  Text(
                    username,
                    style: AppTextStyles.headingLarge,
                  ),
                ],
              ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close_rounded : Icons.search_rounded,
            color: AppColors.charcoal,
          ),
          onPressed: () {
            setState(() => _showSearch = !_showSearch);
            if (!_showSearch) {
              _searchController.clear();
              ref.read(taskFilterProvider.notifier).state =
                  ref.read(taskFilterProvider).copyWith(search: '');
              ref.read(taskListProvider.notifier).loadTasks();
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.person_outline_rounded, color: AppColors.charcoal),
          onPressed: () => context.push('/profile'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Consumer(
      builder: (context, ref, _) {
        final statsAsync = ref.watch(taskStatsProvider);
        return statsAsync.when(
          data: (stats) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: StatsCard(stats: stats),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
          loading: () => const SizedBox(height: 100),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTaskList(TaskListState taskState) {
    if (taskState.isLoading) {
      return const TaskShimmer();
    }

    if (taskState.error != null && taskState.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 56, color: AppColors.charcoal.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(taskState.error!, style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(taskListProvider.notifier).loadTasks(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (taskState.tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'No tasks yet',
        subtitle: 'Tap the + button to create your first task',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: taskState.tasks.length + (taskState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == taskState.tasks.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.terracotta,
              ),
            ),
          );
        }

        final task = taskState.tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  onPressed: (_) => _editTask(task.id),
                  backgroundColor: AppColors.slate,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                SlidableAction(
                  onPressed: (_) => _deleteTask(task),
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                ),
              ],
            ),
            child: TaskCard(
              task: task,
              onTap: () => context.push('/tasks/${task.id}'),
              onToggle: () => _toggleTask(task),
              onEdit: () => _editTask(task.id),
              onDelete: () => _deleteTask(task),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 50 * (index % 10)),
                  duration: 300.ms,
                ),
          ),
        );
      },
    );
  }

  Future<void> _toggleTask(TaskModel task) async {
    final success =
        await ref.read(taskListProvider.notifier).toggleTask(task.id);
    if (!success && mounted) {
      AppSnackbar.showError(context, 'Failed to update task');
    }
  }

  void _editTask(String id) => context.push('/tasks/$id/edit');

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Task', style: AppTextStyles.headingMedium),
        content: Text(
          'Delete "${task.title}"?\nThis action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success =
          await ref.read(taskListProvider.notifier).deleteTask(task.id);
      if (mounted) {
        if (success) {
          AppSnackbar.showSuccess(context, 'Task deleted');
          // Refresh stats
          ref.invalidate(taskStatsProvider);
        } else {
          AppSnackbar.showError(context, 'Failed to delete task');
        }
      }
    }
  }
}
