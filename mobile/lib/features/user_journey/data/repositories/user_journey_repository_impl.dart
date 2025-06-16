import '../../domain/entities/user_journey.dart';
import '../../domain/entities/user_journey_step.dart';
import '../../domain/repositories/user_journey_repository.dart';
import '../datasources/user_journey_local_datasource.dart';
import '../models/user_journey_model.dart';
import '../models/user_journey_step_model.dart';

class UserJourneyRepositoryImpl implements UserJourneyRepository {
  final UserJourneyLocalDataSource localDataSource;

  UserJourneyRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<UserJourney?> getCurrentJourney(String userId) async {
    try {
      final model = await localDataSource.getCurrentJourney(userId);
      return model?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserJourney> createJourney(String userId, String journeyType) async {
    final steps = await getJourneyTemplate(journeyType);
    final journey = UserJourney(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: _getJourneyTitle(journeyType),
      description: _getJourneyDescription(journeyType),
      status: UserJourneyStatus.notStarted,
      steps: steps,
      createdAt: DateTime.now(),
    );

    final model = UserJourneyModel.fromEntity(journey);
    final savedModel = await localDataSource.saveJourney(model);
    return savedModel.toEntity();
  }

  @override
  Future<UserJourney> updateJourney(UserJourney journey) async {
    final model = UserJourneyModel.fromEntity(journey);
    final updatedModel = await localDataSource.updateJourney(model);
    return updatedModel.toEntity();
  }

  @override
  Future<UserJourneyStep> updateStep(String journeyId, UserJourneyStep step) async {
    final model = UserJourneyStepModel.fromEntity(step);
    final updatedModel = await localDataSource.updateStep(journeyId, model);
    return updatedModel.toEntity();
  }

  @override
  Future<UserJourneyStep> startStep(String journeyId, String stepId) async {
    final journey = await localDataSource.getJourneyById(journeyId);
    if (journey == null) throw Exception('Journey not found');

    final step = journey.steps.firstWhere((s) => s.id == stepId);
    final updatedStep = step.copyWith(
      status: UserJourneyStepStatus.inProgress,
      startedAt: DateTime.now(),
    );

    return await updateStep(journeyId, updatedStep);
  }

  @override
  Future<UserJourneyStep> completeStep(
    String journeyId,
    String stepId, {
    Map<String, dynamic>? metadata,
  }) async {
    final journey = await localDataSource.getJourneyById(journeyId);
    if (journey == null) throw Exception('Journey not found');

    final step = journey.steps.firstWhere((s) => s.id == stepId);
    final updatedStep = step.copyWith(
      status: UserJourneyStepStatus.completed,
      completedAt: DateTime.now(),
      progress: 1.0,
      metadata: {...step.metadata, ...?metadata},
    );

    return await updateStep(journeyId, updatedStep);
  }

  @override
  Future<UserJourneyStep> skipStep(
    String journeyId,
    String stepId, {
    String? reason,
  }) async {
    final journey = await localDataSource.getJourneyById(journeyId);
    if (journey == null) throw Exception('Journey not found');

    final step = journey.steps.firstWhere((s) => s.id == stepId);
    final updatedStep = step.copyWith(
      status: UserJourneyStepStatus.skipped,
      completedAt: DateTime.now(),
      metadata: {
        ...step.metadata,
        'skipReason': reason,
      },
    );

    return await updateStep(journeyId, updatedStep);
  }

  @override
  Future<UserJourneyStep> failStep(
    String journeyId,
    String stepId,
    String errorMessage,
  ) async {
    final journey = await localDataSource.getJourneyById(journeyId);
    if (journey == null) throw Exception('Journey not found');

    final step = journey.steps.firstWhere((s) => s.id == stepId);
    final updatedStep = step.copyWith(
      status: UserJourneyStepStatus.failed,
      errorMessage: errorMessage,
    );

    return await updateStep(journeyId, updatedStep);
  }

  @override
  Future<List<UserJourney>> getJourneyHistory(String userId) async {
    final models = await localDataSource.getJourneyHistory(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveProgress(String journeyId, Map<String, dynamic> progressData) async {
    await localDataSource.saveProgress(journeyId, progressData);
  }

  @override
  Future<Map<String, dynamic>?> restoreProgress(String journeyId) async {
    return await localDataSource.restoreProgress(journeyId);
  }

  @override
  Future<void> deleteJourney(String journeyId) async {
    await localDataSource.deleteJourney(journeyId);
  }

  @override
  Future<List<UserJourneyStep>> getJourneyTemplate(String journeyType) async {
    switch (journeyType) {
      case 'onboarding':
        return _getOnboardingTemplate();
      case 'knowledge_creation':
        return _getKnowledgeCreationTemplate();
      default:
        return _getDefaultTemplate();
    }
  }

  @override
  Future<Map<String, dynamic>> getJourneyStats(String userId) async {
    final journeys = await getJourneyHistory(userId);
    
    final completed = journeys.where((j) => j.isCompleted).length;
    final inProgress = journeys.where((j) => j.isInProgress).length;
    final failed = journeys.where((j) => j.isFailed).length;
    
    final totalSteps = journeys.fold<int>(0, (sum, j) => sum + j.totalStepsCount);
    final completedSteps = journeys.fold<int>(0, (sum, j) => sum + j.completedStepsCount);
    
    return {
      'totalJourneys': journeys.length,
      'completedJourneys': completed,
      'inProgressJourneys': inProgress,
      'failedJourneys': failed,
      'totalSteps': totalSteps,
      'completedSteps': completedSteps,
      'completionRate': totalSteps > 0 ? completedSteps / totalSteps : 0.0,
    };
  }

  String _getJourneyTitle(String journeyType) {
    switch (journeyType) {
      case 'onboarding':
        return '新用户引导';
      case 'knowledge_creation':
        return '知识库创建';
      default:
        return '用户旅程';
    }
  }

  String _getJourneyDescription(String journeyType) {
    switch (journeyType) {
      case 'onboarding':
        return '欢迎使用XLoop！让我们一起完成初始设置。';
      case 'knowledge_creation':
        return '创建您的第一个知识库，开始智能知识管理。';
      default:
        return '完成一系列步骤以达成目标。';
    }
  }

  List<UserJourneyStep> _getOnboardingTemplate() {
    return [
      UserJourneyStep(
        id: 'login',
        title: '登录系统',
        description: '使用您的账户登录XLoop平台',
        type: UserJourneyStepType.login,
        status: UserJourneyStepStatus.notStarted,
        order: 1,
      ),
      UserJourneyStep(
        id: 'welcome',
        title: '欢迎界面',
        description: '了解XLoop平台的核心功能和价值',
        type: UserJourneyStepType.welcome,
        status: UserJourneyStepStatus.notStarted,
        order: 2,
        dependencies: ['login'],
      ),
      UserJourneyStep(
        id: 'create_knowledge_base',
        title: '创建知识库',
        description: '创建您的第一个知识库',
        type: UserJourneyStepType.knowledgeBaseCreation,
        status: UserJourneyStepStatus.notStarted,
        order: 3,
        dependencies: ['welcome'],
      ),
      UserJourneyStep(
        id: 'upload_documents',
        title: '上传文档',
        description: '上传文档到知识库中',
        type: UserJourneyStepType.documentUpload,
        status: UserJourneyStepStatus.notStarted,
        order: 4,
        dependencies: ['create_knowledge_base'],
      ),
      UserJourneyStep(
        id: 'test_knowledge',
        title: '测试知识库',
        description: '测试知识库的搜索和问答功能',
        type: UserJourneyStepType.knowledgeTest,
        status: UserJourneyStepStatus.notStarted,
        order: 5,
        dependencies: ['upload_documents'],
      ),
      UserJourneyStep(
        id: 'optimization',
        title: '优化调优',
        description: '根据测试结果优化知识库',
        type: UserJourneyStepType.optimization,
        status: UserJourneyStepStatus.notStarted,
        order: 6,
        dependencies: ['test_knowledge'],
      ),
      UserJourneyStep(
        id: 'completion',
        title: '完成设置',
        description: '恭喜！您已成功完成初始设置',
        type: UserJourneyStepType.completion,
        status: UserJourneyStepStatus.notStarted,
        order: 7,
        dependencies: ['optimization'],
      ),
    ];
  }

  List<UserJourneyStep> _getKnowledgeCreationTemplate() {
    return [
      UserJourneyStep(
        id: 'create_folder',
        title: '创建知识库文件夹',
        description: '为知识库设置名称和基本信息',
        type: UserJourneyStepType.knowledgeBaseCreation,
        status: UserJourneyStepStatus.notStarted,
        order: 1,
      ),
      UserJourneyStep(
        id: 'set_description',
        title: '填写场景简介',
        description: '描述知识库的使用场景和目标',
        type: UserJourneyStepType.knowledgeBaseCreation,
        status: UserJourneyStepStatus.notStarted,
        order: 2,
        dependencies: ['create_folder'],
      ),
      UserJourneyStep(
        id: 'select_category',
        title: '选择知识库类别',
        description: '选择适合的知识库类型',
        type: UserJourneyStepType.knowledgeBaseCreation,
        status: UserJourneyStepStatus.notStarted,
        order: 3,
        dependencies: ['set_description'],
      ),
      UserJourneyStep(
        id: 'set_rules',
        title: '建构匹配规则',
        description: '设置关键词和匹配规则',
        type: UserJourneyStepType.knowledgeBaseCreation,
        status: UserJourneyStepStatus.notStarted,
        order: 4,
        dependencies: ['select_category'],
      ),
      UserJourneyStep(
        id: 'confirm_creation',
        title: '确认新建',
        description: '预览并确认知识库创建',
        type: UserJourneyStepType.knowledgeBaseCreation,
        status: UserJourneyStepStatus.notStarted,
        order: 5,
        dependencies: ['set_rules'],
      ),
    ];
  }

  List<UserJourneyStep> _getDefaultTemplate() {
    return [
      UserJourneyStep(
        id: 'start',
        title: '开始',
        description: '开始您的旅程',
        type: UserJourneyStepType.welcome,
        status: UserJourneyStepStatus.notStarted,
        order: 1,
      ),
    ];
  }
} 