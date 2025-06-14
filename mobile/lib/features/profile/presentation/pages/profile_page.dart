import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// 个人中心页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            _buildUserInfoCard(context),
            
            const SizedBox(height: 24),
            
            // 管理功能区域
            _buildManagementSection(context),
            
            const SizedBox(height: 24),
            
            // 其他功能区域
            _buildOtherSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '管理员',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'admin@xloop.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUserStat('知识库', '5'),
                _buildUserStat('对话', '128'),
                _buildUserStat('文档', '234'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '系统管理',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        // 管理功能列表
        Card(
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.analytics,
                title: '分析仪表板',
                subtitle: '系统性能与质量分析',
                onTap: () => GoRouter.of(context).push('/analytics'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.security,
                title: '权限管理',
                subtitle: '用户权限与角色配置',
                onTap: () => GoRouter.of(context).push('/permissions'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.storage,
                title: '数据管理',
                subtitle: '备份、同步与数据质量',
                onTap: () => GoRouter.of(context).push('/data-management'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.api,
                title: 'API管理',
                subtitle: 'API接口监控与文档',
                onTap: () => GoRouter.of(context).push('/api-management'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '其他功能',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.help_outline,
                title: '帮助中心',
                subtitle: '使用指南与常见问题',
                onTap: () => _showComingSoon(context, '帮助中心'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.feedback,
                title: '意见反馈',
                subtitle: '提交建议与问题反馈',
                onTap: () => _showComingSoon(context, '意见反馈'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: '关于我们',
                subtitle: '应用版本与开发信息',
                onTap: () => _showAboutDialog(context),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.logout,
                title: '退出登录',
                subtitle: '安全退出当前账户',
                onTap: () => _showLogoutDialog(context),
                showArrow: false,
                titleColor: AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: titleColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: showArrow
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.onSurface.withOpacity(0.4),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 68,
      color: AppColors.outline.withOpacity(0.2),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature功能即将推出'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'XLoop智能平台',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.auto_awesome,
          color: AppColors.primary,
          size: 32,
        ),
      ),
      children: [
        const Text('XLoop是一个基于AI驱动的知识智能平台，致力于提升知识管理效率。'),
        const SizedBox(height: 16),
        const Text('版本信息：'),
        const Text('• 应用版本：1.0.0'),
        const Text('• 构建版本：1.0.0+1'),
        const Text('• 发布日期：2024年1月'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现退出登录逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('退出登录功能开发中...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
} 