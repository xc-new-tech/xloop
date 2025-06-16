import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_journey_model.dart';
import '../models/user_journey_step_model.dart';

/// 用户旅程本地数据源
class UserJourneyLocalDataSource {
  static const String _currentJourneyKey = 'current_journey';
  static const String _journeyHistoryKey = 'journey_history';
  static const String _progressKey = 'journey_progress';

  final SharedPreferences sharedPreferences;

  UserJourneyLocalDataSource({required this.sharedPreferences});

  /// 获取当前旅程
  Future<UserJourneyModel?> getCurrentJourney(String userId) async {
    try {
      final jsonString = sharedPreferences.getString('${_currentJourneyKey}_$userId');
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserJourneyModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// 保存旅程
  Future<UserJourneyModel> saveJourney(UserJourneyModel journey) async {
    final jsonString = jsonEncode(journey.toJson());
    await sharedPreferences.setString('${_currentJourneyKey}_${journey.userId}', jsonString);
    
    // 同时保存到历史记录
    await _addToHistory(journey);
    
    return journey;
  }

  /// 更新旅程
  Future<UserJourneyModel> updateJourney(UserJourneyModel journey) async {
    return await saveJourney(journey);
  }

  /// 根据ID获取旅程
  Future<UserJourneyModel?> getJourneyById(String journeyId) async {
    // 首先尝试从当前旅程获取
    final allUsers = await _getAllUserIds();
    for (final userId in allUsers) {
      final journey = await getCurrentJourney(userId);
      if (journey?.id == journeyId) {
        return journey;
      }
    }
    
    // 然后从历史记录中查找
    final history = await _getAllJourneyHistory();
    for (final journey in history) {
      if (journey.id == journeyId) {
        return journey;
      }
    }
    
    return null;
  }

  /// 更新步骤
  Future<UserJourneyStepModel> updateStep(String journeyId, UserJourneyStepModel step) async {
    final journey = await getJourneyById(journeyId);
    if (journey == null) throw Exception('Journey not found');

    final updatedSteps = journey.steps.map((s) {
      return s.id == step.id ? step : s;
    }).toList();

    final updatedJourney = journey.copyWith(
      steps: updatedSteps,
      lastActiveAt: DateTime.now(),
    );

    await updateJourney(updatedJourney);
    return step;
  }

  /// 获取旅程历史
  Future<List<UserJourneyModel>> getJourneyHistory(String userId) async {
    try {
      final jsonString = sharedPreferences.getString('${_journeyHistoryKey}_$userId');
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => UserJourneyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 保存进度
  Future<void> saveProgress(String journeyId, Map<String, dynamic> progressData) async {
    final key = '${_progressKey}_$journeyId';
    final jsonString = jsonEncode(progressData);
    await sharedPreferences.setString(key, jsonString);
  }

  /// 恢复进度
  Future<Map<String, dynamic>?> restoreProgress(String journeyId) async {
    try {
      final key = '${_progressKey}_$journeyId';
      final jsonString = sharedPreferences.getString(key);
      if (jsonString == null) return null;
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 删除旅程
  Future<void> deleteJourney(String journeyId) async {
    final journey = await getJourneyById(journeyId);
    if (journey == null) return;

    // 从当前旅程中删除
    await sharedPreferences.remove('${_currentJourneyKey}_${journey.userId}');
    
    // 从历史记录中删除
    final history = await getJourneyHistory(journey.userId);
    final updatedHistory = history.where((j) => j.id != journeyId).toList();
    await _saveJourneyHistory(journey.userId, updatedHistory);
    
    // 删除进度数据
    await sharedPreferences.remove('${_progressKey}_$journeyId');
  }

  /// 添加到历史记录
  Future<void> _addToHistory(UserJourneyModel journey) async {
    final history = await getJourneyHistory(journey.userId);
    
    // 检查是否已存在，如果存在则更新，否则添加
    final existingIndex = history.indexWhere((j) => j.id == journey.id);
    if (existingIndex >= 0) {
      history[existingIndex] = journey;
    } else {
      history.add(journey);
    }
    
    await _saveJourneyHistory(journey.userId, history);
  }

  /// 保存旅程历史
  Future<void> _saveJourneyHistory(String userId, List<UserJourneyModel> history) async {
    final jsonList = history.map((journey) => journey.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPreferences.setString('${_journeyHistoryKey}_$userId', jsonString);
  }

  /// 获取所有用户ID
  Future<List<String>> _getAllUserIds() async {
    final keys = sharedPreferences.getKeys();
    final userIds = <String>[];
    
    for (final key in keys) {
      if (key.startsWith(_currentJourneyKey)) {
        final userId = key.substring('${_currentJourneyKey}_'.length);
        userIds.add(userId);
      }
    }
    
    return userIds;
  }

  /// 获取所有旅程历史
  Future<List<UserJourneyModel>> _getAllJourneyHistory() async {
    final userIds = await _getAllUserIds();
    final allHistory = <UserJourneyModel>[];
    
    for (final userId in userIds) {
      final history = await getJourneyHistory(userId);
      allHistory.addAll(history);
    }
    
    return allHistory;
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    final keys = sharedPreferences.getKeys().where((key) =>
        key.startsWith(_currentJourneyKey) ||
        key.startsWith(_journeyHistoryKey) ||
        key.startsWith(_progressKey));
    
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
} 