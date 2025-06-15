import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/knowledge_base_bloc.dart';
import '../bloc/knowledge_base_event.dart';
import '../bloc/knowledge_base_state.dart';
import '../../domain/entities/knowledge_base.dart';

class KnowledgeBaseWizardPage extends StatefulWidget {
  const KnowledgeBaseWizardPage({super.key});

  @override
  State<KnowledgeBaseWizardPage> createState() => _KnowledgeBaseWizardPageState();
}

class _KnowledgeBaseWizardPageState extends State<KnowledgeBaseWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // 表单控制器
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordsController = TextEditingController();
  
  // 表单数据
  String _selectedType = 'personal';
  String _selectedCategory = 'product_manual';
  List<String> _keywords = [];
  
  final List<String> _categories = [
    'product_manual',
    'faq_support', 
    'basic_document',
  ];
  
  final Map<String, String> _categoryNames = {
    'product_manual': '产品手册型',
    'faq_support': 'FAQ问题答复型',
    'basic_document': '基础文档型',
  };
  
  final Map<String, String> _categoryDescriptions = {
    'product_manual': '适用于产品说明书、操作手册、技术文档等结构化内容',
    'faq_support': '适用于常见问题解答、客服支持、问题库等问答形式内容',
    'basic_document': '适用于通用文档、报告、资料等各类文档内容',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _addKeyword() {
    final keyword = _keywordsController.text.trim();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      setState(() {
        _keywords.add(keyword);
        _keywordsController.clear();
      });
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  void _createKnowledgeBase() {
    context.read<KnowledgeBaseBloc>().add(
      CreateKnowledgeBaseEvent(
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType == 'personal' 
            ? KnowledgeBaseType.personal 
            : _selectedType == 'team' 
                ? KnowledgeBaseType.team 
                : KnowledgeBaseType.public,
        isPublic: _selectedType == 'public',
        tags: _keywords,
        settings: {
          'category': _selectedCategory,
        },
      ),
    );
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _descriptionController.text.trim().isNotEmpty;
      case 2:
        return true; // 类别选择总是有默认值
      case 3:
        return _keywords.isNotEmpty;
      case 4:
        return true; // 确认页面
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('创建知识库'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<KnowledgeBaseBloc, KnowledgeBaseState>(
        listener: (context, state) {
          if (state is KnowledgeBaseCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is KnowledgeBaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('创建失败: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            // 进度指示器
            Container(
              padding: EdgeInsets.all(20.w),
              color: AppColors.surface,
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: index <= _currentStep 
                            ? AppColors.primary 
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // 步骤内容
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(), // 知识库命名
                  _buildStep2(), // 场景简介
                  _buildStep3(), // 类别选择
                  _buildStep4(), // 匹配规则
                  _buildStep5(), // 确认创建
                ],
              ),
            ),
            
            // 底部按钮
            Container(
              padding: EdgeInsets.all(20.w),
              color: AppColors.surface,
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: CustomButton(
                        text: '上一步',
                        onPressed: _previousStep,
                        isOutlined: true,
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      text: _currentStep == 4 ? '创建知识库' : '下一步',
                      onPressed: _currentStep == 4 
                          ? _createKnowledgeBase
                          : _canProceedFromStep(_currentStep) 
                              ? _nextStep 
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '步骤 1/5',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '为您的知识库命名',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请为您的知识库起一个清晰易懂的名称',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          CustomTextField(
            name: 'knowledge_base_name',
            controller: _nameController,
            label: '知识库名称',
            hintText: '例如：产品使用手册、客服FAQ、技术文档等',
            onChanged: (value) => setState(() {}),
          ),
          
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '建议使用简洁明了的名称，方便后续管理和查找',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '步骤 2/5',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '描述知识库用途',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '简要说明这个知识库的主要用途和包含的内容类型',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          CustomTextField(
            name: 'knowledge_base_description',
            controller: _descriptionController,
            label: '知识库描述',
            hintText: '例如：包含产品功能介绍、操作指南、常见问题解答等内容',
            maxLines: 4,
            onChanged: (value) => setState(() {}),
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '字数统计',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_descriptionController.text.length}/200',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _descriptionController.text.length > 200 
                      ? AppColors.error 
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '步骤 3/5',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '选择知识库类别',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '根据您的内容类型选择最适合的知识库类别',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? AppColors.primary 
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : AppColors.divider,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 12.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _categoryNames[category]!,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _categoryDescriptions[category]!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '步骤 4/5',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '设置匹配标签',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '添加相关标签，帮助系统更好地匹配和检索内容',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'keywords',
                  controller: _keywordsController,
                  label: '添加标签',
                  hintText: '输入标签后点击添加',
                  onSubmitted: (value) => _addKeyword(),
                ),
              ),
              SizedBox(width: 12.w),
              CustomButton(
                text: '添加',
                onPressed: _keywordsController.text.trim().isNotEmpty 
                    ? _addKeyword 
                    : null,
                width: 80.w,
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          if (_keywords.isNotEmpty) ...[
            Text(
              '已添加的标签：',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _keywords.map((keyword) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        keyword,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      InkWell(
                        onTap: () => _removeKeyword(keyword),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '标签建议',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '• 添加与您的内容相关的核心词汇\n• 包含用户可能搜索的术语\n• 建议添加3-10个标签',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '步骤 5/5',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '确认创建知识库',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请确认以下信息无误后创建您的知识库',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmItem('知识库名称', _nameController.text),
                  SizedBox(height: 16.h),
                  _buildConfirmItem('描述', _descriptionController.text),
                  SizedBox(height: 16.h),
                  _buildConfirmItem('类别', _categoryNames[_selectedCategory]!),
                  SizedBox(height: 16.h),
                  _buildConfirmItem(
                    '标签', 
                    _keywords.isEmpty ? '无' : _keywords.join('、'),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '创建完成后，您可以开始上传文档并构建您的知识库',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
} 