class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.fromString(json['status'] as String),
      priority: TaskPriority.fromString(json['priority'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.value,
        'priority': priority.value,
        'dueDate': dueDate?.toIso8601String(),
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'userId': userId,
      };

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now()) && status != TaskStatus.completed;
  }
}

enum TaskStatus {
  pending('PENDING'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => TaskStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

enum TaskPriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  urgent('URGENT');

  final String value;
  const TaskPriority(this.value);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TaskPriority.medium,
    );
  }

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

class TaskStats {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int urgent;
  final int overdue;
  final int completionRate;

  const TaskStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.urgent,
    required this.overdue,
    required this.completionRate,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    return TaskStats(
      total: json['total'] as int,
      pending: json['pending'] as int,
      inProgress: json['inProgress'] as int,
      completed: json['completed'] as int,
      urgent: json['urgent'] as int,
      overdue: json['overdue'] as int,
      completionRate: json['completionRate'] as int,
    );
  }

  factory TaskStats.empty() => const TaskStats(
        total: 0,
        pending: 0,
        inProgress: 0,
        completed: 0,
        urgent: 0,
        overdue: 0,
        completionRate: 0,
      );
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}
