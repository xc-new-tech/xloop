import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../bloc/knowledge_base_bloc.dart';
import '../../bloc/knowledge_base_event.dart';
import '../../bloc/knowledge_base_state.dart';
import '../../../domain/entities/knowledge_base.dart';

class FaqManagementPage extends StatefulWidget {
  final KnowledgeBase knowledgeBase;

  const FaqManagementPage({
    super.key,
    required this.knowledgeBase,
  });

  @override
  State<FaqManagementPage> createState() => _FaqManagementPageState();
}

class _FaqManagementPageState extends State<FaqManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<FaqItem> _faqs = [];
  final Set<String> _selectedFaqs = {};
  bool _isLoading = false;
  bool _isSelectMode = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  void _loadFaqs() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟加载FAQ数据
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _faqs.addAll([
          FaqItem(
            id: '1',
            question: '如何重置密码？',
            answer: '您可以在登录页面点击"忘记密码"链接，然后按照提示操作重置密码。',
            category: '账户管理',
            keywords: ['密码', '重置', '登录'],
            createdBy: '管理员',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          FaqItem(
            id: '2',
            question: '如何上传文档？',
            answer: '在知识库页面点击"上传"按钮，选择您要上传的文档文件，支持PDF、DOC、TXT等格式。',
            category: '文档管理',
            keywords: ['上传', '文档', '文件'],
            createdBy: '管理员',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          FaqItem(
            id: '3',
            question: '支持哪些文件格式？',
            answer: '目前支持PDF、DOC、DOCX、TXT、CSV、PPT、PPTX、MP3等多种格式的文件上传。',
            category: '文档管理',
            keywords: ['格式', '文件', '支持'],
            createdBy: '管理员',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ]);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndActions(),
          Expanded(
            child: _isLoading ? _buildLoading() : _buildFaqList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFaqDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: Colors.white,
                  size: 28.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FAQ 问答管理',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '管理常见问题和标准答案',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSelectMode)
                  TextButton(
                    onPressed: _exitSelectMode,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildStatCard('FAQ总数', '${_faqs.length}'),
                SizedBox(width: 12.w),
                _buildStatCard('分类数', '${_getCategories().length}'),
                SizedBox(width: 12.w),
                _buildStatCard('已选择', _isSelectMode ? '${_selectedFaqs.length}' : '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'search_faqs',
                  controller: _searchController,
                  hintText: '搜索问题或答案...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => _filterFaqs(value ?? ''),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  onPressed: _showFilterDialog,
                  icon: Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (_faqs.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                CustomButton(
                  text: _isSelectMode ? '批量删除' : '批量操作',
                  onPressed: _isSelectMode ? _deleteSelectedFaqs : _enterSelectMode,
                  isOutlined: !_isSelectMode,
                ),
                SizedBox(width: 12.w),
                CustomButton(
                  text: '导入',
                  onPressed: _showImportDialog,
                  isOutlined: true,
                ),
                SizedBox(width: 12.w),
                CustomButton(
                  text: '导出',
                  onPressed: _exportFaqs,
                  isOutlined: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFaqList() {
    if (_faqs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        return _buildFaqCard(faq);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80.w,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无FAQ',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '点击右下角按钮添加第一个FAQ',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(FaqItem faq) {
    final isSelected = _selectedFaqs.contains(faq.id);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: _isSelectMode && isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _isSelectMode ? _toggleSelection(faq.id) : _openFaqDetail(faq),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isSelectMode)
                    Container(
                      margin: EdgeInsets.only(right: 12.w),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleSelection(faq.id),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                faq.category,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'FAQ-${faq.id}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          faq.question,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          faq.answer,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!_isSelectMode)
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleFaqAction(value, faq),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: ListTile(
                            leading: Icon(Icons.visibility),
                            title: Text('查看详情'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('编辑'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'copy',
                          child: ListTile(
                            leading: Icon(Icons.copy),
                            title: Text('复制'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('删除', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: faq.keywords.map((keyword) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    faq.createdBy,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.access_time,
                    size: 14.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDate(faq.updatedAt),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  List<String> _getCategories() {
    return _faqs.map((faq) => faq.category).toSet().toList();
  }

  void _filterFaqs(String query) {
    // TODO: 实现FAQ搜索过滤
  }

  void _showFilterDialog() {
    final categories = _getCategories();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('按分类筛选：'),
            SizedBox(height: 8.h),
            ...categories.map((category) => CheckboxListTile(
              title: Text(category),
              value: true,
              onChanged: (value) {},
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _enterSelectMode() {
    setState(() {
      _isSelectMode = true;
      _selectedFaqs.clear();
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelectMode = false;
      _selectedFaqs.clear();
    });
  }

  void _toggleSelection(String faqId) {
    setState(() {
      if (_selectedFaqs.contains(faqId)) {
        _selectedFaqs.remove(faqId);
      } else {
        _selectedFaqs.add(faqId);
      }
    });
  }

  void _deleteSelectedFaqs() {
    if (_selectedFaqs.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedFaqs.length} 个FAQ吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _faqs.removeWhere((faq) => _selectedFaqs.contains(faq.id));
                _selectedFaqs.clear();
                _isSelectMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已删除选中的FAQ')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('支持导入CSV、Excel格式的FAQ文件'),
            SizedBox(height: 16.h),
            CustomButton(
              text: '选择文件',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文件导入功能开发中...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _exportFaqs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导出FAQ数据...')),
    );
  }

  void _showAddFaqDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    final categoryController = TextEditingController();
    final keywordsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增FAQ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                name: 'faq_question',
                controller: questionController,
                label: '问题',
                hintText: '请输入常见问题',
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                name: 'faq_answer',
                controller: answerController,
                label: '答案',
                hintText: '请输入标准答案',
                maxLines: 4,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                name: 'faq_category',
                controller: categoryController,
                label: '分类',
                hintText: '请输入分类名称',
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                name: 'faq_keywords',
                controller: keywordsController,
                label: '关键词',
                hintText: '请输入关键词，用逗号分隔',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CustomButton(
            text: '创建',
            onPressed: () {
              if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                _addFaq(
                  questionController.text,
                  answerController.text,
                  categoryController.text.isEmpty ? '默认分类' : categoryController.text,
                  keywordsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _addFaq(String question, String answer, String category, List<String> keywords) {
    setState(() {
      _faqs.add(FaqItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: question,
        answer: answer,
        category: category,
        keywords: keywords,
        createdBy: '当前用户',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });
  }

  void _openFaqDetail(FaqItem faq) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看FAQ详情: ${faq.question}')),
    );
  }

  void _handleFaqAction(String action, FaqItem faq) {
    switch (action) {
      case 'view':
        _openFaqDetail(faq);
        break;
      case 'edit':
        // TODO: 编辑FAQ
        break;
      case 'copy':
        // TODO: 复制FAQ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已复制FAQ: ${faq.question}')),
        );
        break;
      case 'delete':
        _showDeleteConfirmDialog(faq);
        break;
    }
  }

  void _showDeleteConfirmDialog(FaqItem faq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除FAQ "${faq.question}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _faqs.remove(faq);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除FAQ: ${faq.question}')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// FAQ数据模型
class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> keywords;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.keywords,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  FaqItem copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    List<String>? keywords,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      keywords: keywords ?? this.keywords,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 