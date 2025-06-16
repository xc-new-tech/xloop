import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/email_notification.dart';
import '../../domain/entities/email_template.dart';

/// 邮件通知管理页面
class EmailNotificationPage extends StatefulWidget {
  const EmailNotificationPage({super.key});

  @override
  State<EmailNotificationPage> createState() => _EmailNotificationPageState();
}

class _EmailNotificationPageState extends State<EmailNotificationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // 模拟数据
  final List<EmailTemplate> _templates = [
    EmailTemplate(
      id: '1',
      name: '账户创建邮件',
      type: EmailTemplateType.accountCreation,
      subject: '欢迎加入XLoop知识智能平台',
      htmlContent: '<h1>欢迎您！</h1><p>您的账户已创建成功。</p>',
      textContent: '欢迎您！您的账户已创建成功。',
      variables: {'username': '用户名', 'password': '初始密码'},
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    EmailTemplate(
      id: '2',
      name: '密码重置邮件',
      type: EmailTemplateType.passwordReset,
      subject: '密码重置请求',
      htmlContent: '<h1>密码重置</h1><p>点击链接重置密码。</p>',
      textContent: '密码重置 - 点击链接重置密码。',
      variables: {'resetLink': '重置链接', 'expireTime': '过期时间'},
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final List<EmailNotification> _notifications = [
    EmailNotification(
      id: '1',
      to: 'user@example.com',
      subject: '欢迎加入XLoop知识智能平台',
      htmlContent: '<h1>欢迎您！</h1>',
      textContent: '欢迎您！',
      status: EmailStatus.sent,
      templateId: '1',
      variables: {'username': 'John', 'password': 'temp123'},
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    EmailNotification(
      id: '2',
      to: 'test@example.com',
      subject: '密码重置请求',
      htmlContent: '<h1>密码重置</h1>',
      textContent: '密码重置',
      status: EmailStatus.failed,
      templateId: '2',
      variables: {'resetLink': 'https://...', 'expireTime': '24小时'},
      errorMessage: '邮箱地址无效',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '邮件通知系统',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('创建模板功能开发中...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab栏
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: '邮件模板'),
                Tab(text: '发送历史'),
                Tab(text: '统计分析'),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplatesTab(),
                _buildNotificationsTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 邮件模板标签页
  Widget _buildTemplatesTab() {
    return Column(
      children: [
        // 搜索栏
        Container(
          padding: EdgeInsets.all(16.w),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'search',
                  controller: _searchController,
                  hintText: '搜索邮件模板...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              SizedBox(width: 12.w),
              CustomButton(
                text: '筛选',
                onPressed: _showFilterDialog,
                isOutlined: true,
                width: 80,
              ),
            ],
          ),
        ),
        // 模板列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              return _buildTemplateCard(template);
            },
          ),
        ),
      ],
    );
  }

  /// 邮件模板卡片
  Widget _buildTemplateCard(EmailTemplate template) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        template.subject,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTemplateTypeChip(template.type),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  template.language,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.update,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  '更新于 ${_formatDate(template.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _previewTemplate(template),
                  child: const Text('预览'),
                ),
                TextButton(
                  onPressed: () => _editTemplate(template),
                  child: const Text('编辑'),
                ),
                TextButton(
                  onPressed: () => _deleteTemplate(template),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('删除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 发送历史标签页
  Widget _buildNotificationsTab() {
    return Column(
      children: [
        // 筛选栏
        Container(
          padding: EdgeInsets.all(16.w),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'search_notifications',
                  hintText: '搜索邮件地址...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              SizedBox(width: 12.w),
              CustomButton(
                text: '筛选',
                onPressed: _showNotificationFilterDialog,
                isOutlined: true,
                width: 80,
              ),
            ],
          ),
        ),
        // 通知列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        ),
      ],
    );
  }

  /// 邮件通知卡片
  Widget _buildNotificationCard(EmailNotification notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.to,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.subject,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(notification.status),
              ],
            ),
            if (notification.errorMessage != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        notification.errorMessage!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  '创建于 ${_formatDate(notification.createdAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (notification.sentAt != null) ...[
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.send,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '发送于 ${_formatDate(notification.sentAt!)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (notification.canRetry) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: '重试发送',
                    onPressed: () => _retryNotification(notification),
                    width: 100,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 统计分析标签页
  Widget _buildStatisticsTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // 统计卡片
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '总发送量',
                  '1,234',
                  Icons.email,
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  '成功率',
                  '98.5%',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '失败数量',
                  '18',
                  Icons.error,
                  AppColors.error,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  '待发送',
                  '5',
                  Icons.schedule,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // 图表区域（占位）
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Center(
                child: Text('邮件发送趋势图表'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 模板类型标签
  Widget _buildTemplateTypeChip(EmailTemplateType type) {
    String text;
    Color color;
    
    switch (type) {
      case EmailTemplateType.accountCreation:
        text = '账户创建';
        color = AppColors.primary;
        break;
      case EmailTemplateType.passwordReset:
        text = '密码重置';
        color = AppColors.warning;
        break;
      case EmailTemplateType.emailVerification:
        text = '邮箱验证';
        color = AppColors.info;
        break;
      case EmailTemplateType.welcome:
        text = '欢迎邮件';
        color = AppColors.success;
        break;
      case EmailTemplateType.notification:
        text = '通知邮件';
        color = AppColors.secondary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 状态标签
  Widget _buildStatusChip(EmailStatus status) {
    String text;
    Color color;
    
    switch (status) {
      case EmailStatus.pending:
        text = '待发送';
        color = AppColors.warning;
        break;
      case EmailStatus.sending:
        text = '发送中';
        color = AppColors.info;
        break;
      case EmailStatus.sent:
        text = '已发送';
        color = AppColors.success;
        break;
      case EmailStatus.failed:
        text = '发送失败';
        color = AppColors.error;
        break;
      case EmailStatus.retrying:
        text = '重试中';
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 显示筛选对话框
  void _showFilterDialog() {
    // TODO: 实现筛选对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('筛选功能开发中...')),
    );
  }

  /// 显示通知筛选对话框
  void _showNotificationFilterDialog() {
    // TODO: 实现通知筛选对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知筛选功能开发中...')),
    );
  }

  /// 预览模板
  void _previewTemplate(EmailTemplate template) {
    // TODO: 实现模板预览
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('预览模板: ${template.name}')),
    );
  }

  /// 编辑模板
  void _editTemplate(EmailTemplate template) {
    // TODO: 实现模板编辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑模板: ${template.name}')),
    );
  }

  /// 删除模板
  void _deleteTemplate(EmailTemplate template) {
    // TODO: 实现模板删除
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('删除模板: ${template.name}')),
    );
  }

  /// 重试通知
  void _retryNotification(EmailNotification notification) {
    // TODO: 实现重试发送
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('重试发送邮件到: ${notification.to}')),
    );
  }
} 