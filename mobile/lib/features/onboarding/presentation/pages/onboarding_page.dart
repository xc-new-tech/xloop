import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/onboarding_step_widget.dart';
import '../bloc/onboarding_bloc.dart';
import '../../domain/entities/onboarding_step.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 加载用户引导进度
    context.read<OnboardingBloc>().add(
      const LoadOnboardingProgress(userId: 'current_user'), // TODO: 获取实际用户ID
    );
  }

  final List<OnboardingStep> _steps = [
    const OnboardingStep(
      id: 'step1',
      title: '创建知识库',
      description: '为您的文档和知识创建一个专属空间，支持多种类型的知识库管理。',
      imageUrl: 'assets/images/onboarding_step1.png',
    ),
    const OnboardingStep(
      id: 'step2',
      title: '上传文档',
      description: '支持多种格式的文档上传，包括PDF、Word、Excel、PPT等常见格式。',
      imageUrl: 'assets/images/onboarding_step2.png',
    ),
    const OnboardingStep(
      id: 'step3',
      title: '智能解析',
      description: 'AI自动解析文档内容，提取关键信息，构建知识图谱。',
      imageUrl: 'assets/images/onboarding_step3.png',
    ),
    const OnboardingStep(
      id: 'step4',
      title: '语义检索',
      description: '基于语义理解的智能搜索，快速找到您需要的信息。',
      imageUrl: 'assets/images/onboarding_step4.png',
    ),
    const OnboardingStep(
      id: 'step5',
      title: '智能问答',
      description: '与您的知识库对话，获得准确的答案和建议。',
      imageUrl: 'assets/images/onboarding_step5.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingCompleted) {
              _showCompletionAnimation();
            } else if (state is OnboardingSkipped) {
              _goToMain();
            }
          },
          child: Column(
            children: [
              // 顶部导航栏
              _buildTopBar(),
              
              // 进度指示器
              _buildProgressIndicator(),
              
              // 引导内容
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    // 更新当前步骤
                    context.read<OnboardingBloc>().add(
                      UpdateCurrentStep(stepId: _steps[index].id),
                    );
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return OnboardingStepWidget(
                      step: _steps[index],
                      isActive: index == _currentIndex,
                    );
                  },
                ),
              ),
              
              // 底部按钮
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          if (_currentIndex > 0)
            IconButton(
              onPressed: _previousStep,
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20.w,
                color: AppColors.textSecondary,
              ),
            )
          else
            SizedBox(width: 48.w),
          
          // 标题
          Text(
            '新手引导',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          // 跳过按钮
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              '跳过',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // 进度条
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _steps.length,
            backgroundColor: AppColors.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4.h,
          ),
          
          SizedBox(height: 8.h),
          
          // 进度文本
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 ${_currentIndex + 1} 步',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_currentIndex + 1}/${_steps.length}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          // 上一步按钮
          if (_currentIndex > 0)
            Expanded(
              child: CustomButton(
                text: '上一步',
                onPressed: _previousStep,
                isOutlined: true,
              ),
            ),
          
          if (_currentIndex > 0) SizedBox(width: 16.w),
          
          // 下一步/完成按钮
          Expanded(
            flex: _currentIndex > 0 ? 1 : 2,
            child: CustomButton(
              text: _isLastStep ? '开始使用' : '下一步',
              onPressed: _isLastStep ? _completeOnboarding : _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isLastStep => _currentIndex == _steps.length - 1;

  void _nextStep() {
    if (_currentIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('跳过引导'),
        content: const Text('您确定要跳过新手引导吗？您可以稍后在设置中重新查看。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<OnboardingBloc>().add(const SkipOnboarding());
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() {
    // 标记当前步骤完成
    context.read<OnboardingBloc>().add(
      CompleteOnboardingStep(stepId: _steps[_currentIndex].id),
    );
    
    // 完成整个引导流程
    context.read<OnboardingBloc>().add(const CompleteOnboardingFlow());
  }

  void _showCompletionAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64.w,
              color: AppColors.success,
            ),
            SizedBox(height: 16.h),
            Text(
              '引导完成！',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '现在您可以开始创建您的第一个知识库了',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: '开始创建',
            onPressed: () {
              Navigator.of(context).pop();
              _goToKnowledgeBaseCreation();
            },
          ),
        ],
      ),
    );
  }

  void _goToMain() {
    context.go('/knowledge-base');
  }

  void _goToKnowledgeBaseCreation() {
    context.go('/knowledge-base/create');
  }
} 