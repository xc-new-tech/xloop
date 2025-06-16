import '../entities/user_journey.dart';
import '../entities/user_journey_step.dart';

/// 用户旅程仓库接口
abstract class UserJourneyRepository {
  /// 获取用户的当前旅程
  Future<UserJourney?> getCurrentJourney(String userId);

  /// 创建新的用户旅程
  Future<UserJourney> createJourney(String userId, String journeyType);

  /// 更新用户旅程
  Future<UserJourney> updateJourney(UserJourney journey);

  /// 更新旅程步骤
  Future<UserJourneyStep> updateStep(String journeyId, UserJourneyStep step);

  /// 开始步骤
  Future<UserJourneyStep> startStep(String journeyId, String stepId);

  /// 完成步骤
  Future<UserJourneyStep> completeStep(String journeyId, String stepId, {Map<String, dynamic>? metadata});

  /// 跳过步骤
  Future<UserJourneyStep> skipStep(String journeyId, String stepId, {String? reason});

  /// 标记步骤失败
  Future<UserJourneyStep> failStep(String journeyId, String stepId, String errorMessage);

  /// 获取旅程历史
  Future<List<UserJourney>> getJourneyHistory(String userId);

  /// 保存旅程进度
  Future<void> saveProgress(String journeyId, Map<String, dynamic> progressData);

  /// 恢复旅程进度
  Future<Map<String, dynamic>?> restoreProgress(String journeyId);

  /// 删除旅程
  Future<void> deleteJourney(String journeyId);

  /// 获取旅程模板
  Future<List<UserJourneyStep>> getJourneyTemplate(String journeyType);

  /// 获取用户旅程统计
  Future<Map<String, dynamic>> getJourneyStats(String userId);
} 