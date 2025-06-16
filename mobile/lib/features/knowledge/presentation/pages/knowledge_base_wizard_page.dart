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
  
  // 预设模板
  final Map<String, Map<String, dynamic>> _templates = {
    'product_manual': {
      'keywords': ['产品', '功能', '操作', '使用', '说明', '指南'],
      'description': '本知识库主要用于存储产品功能介绍、操作指南、使用说明等内容，帮助用户快速了解产品特性和使用方法，解决使用过程中遇到的问题。',
    },
    'faq_support': {
      'keywords': ['问题', '解答', '帮助', '支持', '常见', '疑问'],
      'description': '本知识库专门收集和整理常见问题及其标准答案，为客服人员和用户提供快速、准确的问题解决方案，提高服务效率和用户满意度。',
    },
    'basic_document': {
      'keywords': ['文档', '资料', '信息', '知识', '内容', '数据'],
      'description': '本知识库用于存储各类通用文档、技术资料、业务信息等内容，建立统一的知识管理平台，方便团队成员查找和共享相关信息。',
    },
  };
  
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
  
  void _applyTemplate(String category) {
    final template = _templates[category];
    if (template != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('应用模板'),
          content: Text('是否要应用${_categoryNames[category]}的预设模板？\n\n这将自动填充场景简介和关键词。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if (_descriptionController.text.trim().isEmpty) {
                    _descriptionController.text = template['description'] as String;
                  }
                  if (_keywords.isEmpty) {
                    _keywords = List<String>.from(template['keywords'] as List);
                  }
                });
              },
              child: const Text('应用'),
            ),
          ],
        ),
      );
    }
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
        contentType: KnowledgeBaseContentTypeExtension.fromValue(_selectedCategory),
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
        // 步骤1：知识库名称必填且格式正确
        final name = _nameController.text.trim();
        return name.isNotEmpty && name.length >= 2 && name.length <= 50;
      case 1:
        // 步骤2：场景简介必填且不超过200字
        final description = _descriptionController.text.trim();
        return description.isNotEmpty && 
               description.length >= 10 && 
               description.length <= 200;
      case 2:
        // 步骤3：类别选择总是有默认值
        return true;
      case 3:
        // 步骤4：至少需要添加一个关键词
        return _keywords.isNotEmpty;
      case 4:
        // 步骤5：确认页面
        return true;
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
            '创建知识库文件夹',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '为您的知识库创建一个专属的文件夹，用于存储和管理相关文档',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          CustomTextField(
            name: 'knowledge_base_name',
            controller: _nameController,
            label: '知识库文件夹名称 *',
            hintText: '例如：产品使用手册、客服FAQ、技术文档等',
            onChanged: (value) => setState(() {}),
            validators: [
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入知识库名称';
                }
                if (value.trim().length < 2) {
                  return '知识库名称至少需要2个字符';
                }
                if (value.trim().length > 50) {
                  return '知识库名称不能超过50个字符';
                }
                return null;
              },
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 实时校验提示
          if (_nameController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _nameController.text.trim().length >= 2 && _nameController.text.trim().length <= 50
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _nameController.text.trim().length >= 2 && _nameController.text.trim().length <= 50
                      ? Colors.green.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _nameController.text.trim().length >= 2 && _nameController.text.trim().length <= 50
                        ? Icons.check_circle_outline
                        : Icons.warning_outlined,
                    color: _nameController.text.trim().length >= 2 && _nameController.text.trim().length <= 50
                        ? Colors.green
                        : Colors.orange,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _nameController.text.trim().length >= 2 && _nameController.text.trim().length <= 50
                          ? '名称格式正确'
                          : _nameController.text.trim().length < 2
                              ? '名称至少需要2个字符'
                              : '名称不能超过50个字符',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _nameController.text.trim().length >= 2 && _nameController.text.trim().length <= 50
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
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
                  Icons.folder_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '文件夹名称将作为知识库的唯一标识，创建后不可修改，请谨慎命名',
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
    final currentLength = _descriptionController.text.length;
    final isOverLimit = currentLength > 200;
    
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
            '填写知识库场景简介',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '详细描述知识库的应用场景、主要用途和包含的内容类型，帮助系统更好地理解和组织您的知识',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          CustomTextField(
            name: 'knowledge_base_description',
            controller: _descriptionController,
            label: '知识库场景简介 *',
            hintText: '例如：本知识库主要用于存储产品功能介绍、操作指南、常见问题解答等内容，帮助用户快速了解产品使用方法和解决常见问题...',
            maxLines: 6,
            onChanged: (value) => setState(() {}),
            validators: [
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请填写知识库场景简介';
                }
                if (value.trim().length < 10) {
                  return '场景简介至少需要10个字符';
                }
                if (value.length > 200) {
                  return '场景简介不能超过200个字符';
                }
                return null;
              },
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // 使用模板按钮
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '使用${_categoryNames[_selectedCategory]}模板',
                  onPressed: () => _applyTemplate(_selectedCategory),
                  isOutlined: true,
                  icon: Icon(
                    Icons.auto_awesome_outlined,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // 字数统计和提示
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
                '$currentLength/200',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isOverLimit 
                      ? AppColors.error 
                      : currentLength > 180
                          ? Colors.orange
                          : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 字数限制提示
          if (isOverLimit)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '场景简介超出200字限制，请精简内容',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (currentLength > 180)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.orange,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '即将达到字数限制，还可输入${200 - currentLength}个字符',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
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
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '撰写建议',
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
                  '• 描述知识库的具体应用场景和目标用户\n• 说明包含的主要内容类型和范围\n• 突出知识库的核心价值和特色\n• 使用清晰简洁的语言，避免过于技术性的术语',
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
                  Icons.auto_awesome_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '选择类别后，在下一步可以使用预设模板快速填充场景简介和关键词',
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
            '建构匹配规则',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '添加关键词和标签，建立智能匹配规则，提高内容检索的准确性和相关性',
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
                  label: '添加关键词',
                  hintText: '输入与知识库内容相关的关键词',
                  onSubmitted: (value) => _addKeyword(),
                  validators: [
                    (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length < 2) {
                          return '关键词至少需要2个字符';
                        }
                        if (value.trim().length > 20) {
                          return '关键词不能超过20个字符';
                        }
                        if (_keywords.contains(value.trim())) {
                          return '该关键词已存在';
                        }
                      }
                      return null;
                    },
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              CustomButton(
                text: '添加',
                onPressed: _keywordsController.text.trim().isNotEmpty && 
                          _keywordsController.text.trim().length >= 2 &&
                          _keywordsController.text.trim().length <= 20 &&
                          !_keywords.contains(_keywordsController.text.trim())
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
            '确认新建知识库',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请仔细检查以下配置信息，确认无误后点击"创建知识库"完成设置',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 基本信息
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '基本信息',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildConfirmItem('文件夹名称', _nameController.text),
                        SizedBox(height: 16.h),
                        _buildConfirmItem('知识库类别', _categoryNames[_selectedCategory]!),
                        SizedBox(height: 16.h),
                        _buildConfirmItem('类别说明', _categoryDescriptions[_selectedCategory]!),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // 场景简介
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '场景简介',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            _descriptionController.text.isNotEmpty 
                                ? _descriptionController.text 
                                : '暂无描述',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '字数：${_descriptionController.text.length}/200',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // 匹配规则
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '匹配规则',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        if (_keywords.isNotEmpty) ...[
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
                                child: Text(
                                  keyword,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '共${_keywords.length}个关键词',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ] else
                          Text(
                            '暂无关键词',
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
                  Icons.rocket_launch_outlined,
                  color: Colors.green,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '知识库创建完成后，您可以立即开始上传文档、构建知识图谱，并享受智能问答服务',
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