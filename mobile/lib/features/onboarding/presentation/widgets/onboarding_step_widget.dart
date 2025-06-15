import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/onboarding_step.dart';

class OnboardingStepWidget extends StatefulWidget {
  final OnboardingStep step;
  final bool isActive;

  const OnboardingStepWidget({
    super.key,
    required this.step,
    required this.isActive,
  });

  @override
  State<OnboardingStepWidget> createState() => _OnboardingStepWidgetState();
}

class _OnboardingStepWidgetState extends State<OnboardingStepWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(OnboardingStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      _startAnimations();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 插图区域
              _buildIllustration(),
              
              SizedBox(height: 48.h),
              
              // 标题
              Text(
                widget.step.title,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              // 描述
              Text(
                widget.step.description,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32.h),
              
              // 功能亮点
              _buildFeatureHighlights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 280.w,
      height: 280.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildStepIcon(),
    );
  }

  Widget _buildStepIcon() {
    IconData icon;
    Color iconColor;
    
    switch (widget.step.id) {
      case 'step1':
        icon = Icons.create_new_folder_outlined;
        iconColor = AppColors.primary;
        break;
      case 'step2':
        icon = Icons.cloud_upload_outlined;
        iconColor = AppColors.secondary;
        break;
      case 'step3':
        icon = Icons.auto_awesome_outlined;
        iconColor = AppColors.secondary;
        break;
      case 'step4':
        icon = Icons.search_outlined;
        iconColor = AppColors.info;
        break;
      case 'step5':
        icon = Icons.chat_bubble_outline;
        iconColor = AppColors.success;
        break;
      default:
        icon = Icons.help_outline;
        iconColor = AppColors.textSecondary;
    }

    return Center(
      child: Container(
        width: 120.w,
        height: 120.w,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(60.r),
        ),
        child: Icon(
          icon,
          size: 60.w,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    List<String> highlights;
    
    switch (widget.step.id) {
      case 'step1':
        highlights = ['支持多种知识库类型', '灵活的权限管理', '团队协作功能'];
        break;
      case 'step2':
        highlights = ['支持多种文件格式', '批量上传功能', '自动格式识别'];
        break;
      case 'step3':
        highlights = ['AI智能解析', '自动提取关键信息', '构建知识图谱'];
        break;
      case 'step4':
        highlights = ['语义理解搜索', '快速精准定位', '智能推荐相关内容'];
        break;
      case 'step5':
        highlights = ['自然语言对话', '准确答案生成', '上下文理解'];
        break;
      default:
        highlights = [];
    }

    return Column(
      children: highlights.map((highlight) => _buildHighlightItem(highlight)).toList(),
    );
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.w,
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 