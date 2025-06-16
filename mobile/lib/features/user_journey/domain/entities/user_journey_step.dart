/// 用户旅程步骤状态
enum UserJourneyStepStatus {
  notStarted,
  inProgress,
  completed,
  skipped,
  failed,
}

/// 用户旅程步骤类型
enum UserJourneyStepType {
  login,
  welcome,
  knowledgeBaseCreation,
  documentUpload,
  knowledgeTest,
  optimization,
  completion,
}

/// 用户旅程步骤实体
class UserJourneyStep {
  final String id;
  final String title;
  final String description;
  final UserJourneyStepType type;
  final UserJourneyStepStatus status;
  final int order;
  final List<String> dependencies;
  final Map<String, dynamic> metadata;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final double progress; // 0.0 - 1.0

  const UserJourneyStep({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.order,
    this.dependencies = const [],
    this.metadata = const {},
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.progress = 0.0,
  });

  UserJourneyStep copyWith({
    String? id,
    String? title,
    String? description,
    UserJourneyStepType? type,
    UserJourneyStepStatus? status,
    int? order,
    List<String>? dependencies,
    Map<String, dynamic>? metadata,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    double? progress,
  }) {
    return UserJourneyStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      order: order ?? this.order,
      dependencies: dependencies ?? this.dependencies,
      metadata: metadata ?? this.metadata,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  /// 是否可以开始
  bool canStart(List<UserJourneyStep> allSteps) {
    if (status == UserJourneyStepStatus.completed) return false;
    
    // 检查依赖是否完成
    for (final depId in dependencies) {
      final dep = allSteps.firstWhere(
        (step) => step.id == depId,
        orElse: () => throw Exception('Dependency $depId not found'),
      );
      if (dep.status != UserJourneyStepStatus.completed) {
        return false;
      }
    }
    
    return true;
  }

  /// 是否已完成
  bool get isCompleted => status == UserJourneyStepStatus.completed;

  /// 是否进行中
  bool get isInProgress => status == UserJourneyStepStatus.inProgress;

  /// 是否失败
  bool get isFailed => status == UserJourneyStepStatus.failed;

  /// 获取状态显示文本
  String get statusText {
    switch (status) {
      case UserJourneyStepStatus.notStarted:
        return '未开始';
      case UserJourneyStepStatus.inProgress:
        return '进行中';
      case UserJourneyStepStatus.completed:
        return '已完成';
      case UserJourneyStepStatus.skipped:
        return '已跳过';
      case UserJourneyStepStatus.failed:
        return '失败';
    }
  }

  /// 获取类型显示文本
  String get typeText {
    switch (type) {
      case UserJourneyStepType.login:
        return '登录';
      case UserJourneyStepType.welcome:
        return '欢迎';
      case UserJourneyStepType.knowledgeBaseCreation:
        return '知识库创建';
      case UserJourneyStepType.documentUpload:
        return '文档上传';
      case UserJourneyStepType.knowledgeTest:
        return '知识测试';
      case UserJourneyStepType.optimization:
        return '优化调优';
      case UserJourneyStepType.completion:
        return '完成';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserJourneyStep &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserJourneyStep{id: $id, title: $title, status: $status, progress: $progress}';
  }
} 