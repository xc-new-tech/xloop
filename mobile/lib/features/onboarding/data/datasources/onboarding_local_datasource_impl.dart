import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/onboarding_progress.dart';
import '../models/onboarding_progress_model.dart';
import 'onboarding_local_datasource.dart';

class OnboardingLocalDatasourceImpl implements OnboardingLocalDatasource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDatasourceImpl({required this.sharedPreferences});

  static const String _onboardingProgressKey = 'onboarding_progress_';

  @override
  Future<OnboardingProgress> getOnboardingProgress(String userId) async {
    final key = _onboardingProgressKey + userId;
    final jsonString = sharedPreferences.getString(key);
    
    if (jsonString == null) {
      throw Exception('Onboarding progress not found');
    }
    
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return OnboardingProgressModel.fromJson(jsonMap);
  }

  @override
  Future<void> saveOnboardingProgress(OnboardingProgress progress) async {
    final key = _onboardingProgressKey + progress.userId;
    final model = OnboardingProgressModel.fromEntity(progress);
    final jsonString = json.encode(model.toJson());
    
    await sharedPreferences.setString(key, jsonString);
  }

  @override
  Future<void> clearOnboardingProgress(String userId) async {
    final key = _onboardingProgressKey + userId;
    await sharedPreferences.remove(key);
  }
} 