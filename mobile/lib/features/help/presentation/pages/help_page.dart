import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 帮助中心页面
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助中心'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '常见问题'),
            Tab(text: '使用指南'),
            Tab(text: '联系我们'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildGuideTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFAQSection(
          title: '账户相关',
          questions: [
            {
              'question': '如何注册账户？',
              'answer': '点击登录页面的"注册"按钮，填写邮箱、密码等信息即可完成注册。',
            },
            {
              'question': '忘记密码怎么办？',
              'answer': '在登录页面点击"忘记密码"，输入注册邮箱，系统会发送重置密码链接到您的邮箱。',
            },
            {
              'question': '如何修改个人信息？',
              'answer': '进入"个人资料"页面，点击相应字段即可修改个人信息。',
            },
          ],
        ),
        const SizedBox(height: 24),
        _buildFAQSection(
          title: '功能使用',
          questions: [
            {
              'question': '如何创建知识库？',
              'answer': '在知识库页面点击"+"按钮，填写知识库名称和描述，选择权限设置后即可创建。',
            },
            {
              'question': '支持哪些文件格式？',
              'answer': 'XLoop支持PDF、Word、Excel、PowerPoint、TXT、Markdown等多种常见文件格式。',
            },
            {
              'question': '如何进行语义搜索？',
              'answer': '在搜索框中输入关键词，选择"语义搜索"模式，系统会基于内容理解返回相关结果。',
            },
          ],
        ),
        const SizedBox(height: 24),
        _buildFAQSection(
          title: '技术支持',
          questions: [
            {
              'question': '应用崩溃怎么办？',
              'answer': '请尝试重启应用，如果问题持续存在，请通过"联系我们"反馈问题详情。',
            },
            {
              'question': '同步失败怎么处理？',
              'answer': '检查网络连接是否正常，如果网络正常仍无法同步，请联系技术支持。',
            },
            {
              'question': '如何备份数据？',
              'answer': '在设置页面选择"导出数据"，可以将您的数据导出到本地进行备份。',
            },
          ],
        ),
      ],
    );
  }

  Widget _buildGuideTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGuideCard(
          title: '快速开始',
          icon: Icons.rocket_launch,
          description: '了解XLoop的基础功能，快速上手',
          steps: [
            '注册并登录账户',
            '创建您的第一个知识库',
            '上传文档或添加内容',
            '开始智能对话和搜索',
          ],
        ),
        const SizedBox(height: 20),
        _buildGuideCard(
          title: '知识库管理',
          icon: Icons.library_books,
          description: '学习如何有效管理知识库',
          steps: [
            '创建不同主题的知识库',
            '上传和管理文档',
            '设置访问权限',
            '优化知识库结构',
          ],
        ),
        const SizedBox(height: 20),
        _buildGuideCard(
          title: '智能对话',
          icon: Icons.chat,
          description: '掌握与AI的对话技巧',
          steps: [
            '选择合适的对话模式',
            '提出清晰具体的问题',
            '利用上下文进行多轮对话',
            '保存重要对话记录',
          ],
        ),
        const SizedBox(height: 20),
        _buildGuideCard(
          title: '高级功能',
          icon: Icons.settings,
          description: '探索XLoop的高级特性',
          steps: [
            '使用语义搜索功能',
            '配置个性化设置',
            '管理用户权限',
            '查看分析报告',
          ],
        ),
      ],
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildContactCard(
          title: '技术支持',
          icon: Icons.support_agent,
          content: [
            '邮箱：support@xloop.com',
            '工作时间：周一至周五 9:00-18:00',
            '响应时间：24小时内回复',
          ],
        ),
        const SizedBox(height: 20),
        _buildContactCard(
          title: '商务合作',
          icon: Icons.business,
          content: [
            '邮箱：business@xloop.com',
            '电话：400-123-4567',
            '地址：北京市朝阳区xxx路xxx号',
          ],
        ),
        const SizedBox(height: 20),
        _buildContactCard(
          title: '意见反馈',
          icon: Icons.feedback,
          content: [
            '邮箱：feedback@xloop.com',
            'QQ群：123456789',
            '微信群：联系客服获取二维码',
          ],
        ),
        const SizedBox(height: 20),
        _buildContactCard(
          title: '社交媒体',
          icon: Icons.share,
          content: [
            '官方网站：www.xloop.com',
            '微信公众号：XLoop智能助手',
            '新浪微博：@XLoop官方',
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                '紧急问题处理',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '如遇到紧急技术问题，请直接拨打客服热线：400-123-4567\n我们将为您提供7×24小时紧急技术支持',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection({
    required String title,
    required List<Map<String, String>> questions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...questions.map((q) => _buildFAQItem(
          question: q['question']!,
          answer: q['answer']!,
        )),
      ],
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required String title,
    required IconData icon,
    required String description,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required IconData icon,
    required List<String> content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )),
        ],
      ),
    );
  }
} 