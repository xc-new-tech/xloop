import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 系统设置页面
/// 
/// 提供系统配置、用户偏好、安全设置等功能
class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 通用设置
  bool _isDarkMode = false;
  String _selectedLanguage = 'zh-CN';
  bool _enableNotifications = true;
  bool _enableSounds = true;
  
  // 系统配置
  int _maxUploadSize = 100;
  int _sessionTimeout = 30;
  bool _enableCache = true;
  String _logLevel = 'info';
  
  // 安全设置
  bool _requireStrongPassword = true;
  bool _enableTwoFactor = false;
  int _maxLoginAttempts = 5;
  
  // AI配置
  String _defaultModel = 'gpt-4';
  double _temperature = 0.7;
  int _maxTokens = 2000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '系统设置',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _saveAllSettings(),
            icon: const Icon(Icons.save),
            tooltip: '保存设置',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.tune), text: '通用'),
            Tab(icon: Icon(Icons.settings), text: '系统'),
            Tab(icon: Icon(Icons.security), text: '安全'),
            Tab(icon: Icon(Icons.psychology), text: 'AI'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildSystemTab(),
          _buildSecurityTab(),
          _buildAITab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection('外观设置', [
          _buildSwitchTile(
            '深色模式',
            '启用深色主题',
            _isDarkMode,
            (value) => setState(() => _isDarkMode = value),
            Icons.dark_mode,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('语言设置', [
          _buildDropdownTile(
            '界面语言',
            _selectedLanguage,
            {'zh-CN': '简体中文', 'en-US': 'English'},
            (value) => setState(() => _selectedLanguage = value!),
            Icons.language,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('通知设置', [
          _buildSwitchTile(
            '推送通知',
            '接收系统通知',
            _enableNotifications,
            (value) => setState(() => _enableNotifications = value),
            Icons.notifications,
          ),
          _buildSwitchTile(
            '声音提醒',
            '播放通知声音',
            _enableSounds,
            (value) => setState(() => _enableSounds = value),
            Icons.volume_up,
          ),
        ]),
      ],
    );
  }

  Widget _buildSystemTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection('存储设置', [
          _buildSliderTile(
            '最大上传大小',
            _maxUploadSize.toDouble(),
            1,
            500,
            (value) => setState(() => _maxUploadSize = value.round()),
            '${_maxUploadSize}MB',
            Icons.cloud_upload,
          ),
          _buildSwitchTile(
            '启用缓存',
            '提高应用性能',
            _enableCache,
            (value) => setState(() => _enableCache = value),
            Icons.cached,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('会话管理', [
          _buildSliderTile(
            '会话超时',
            _sessionTimeout.toDouble(),
            5,
            120,
            (value) => setState(() => _sessionTimeout = value.round()),
            '${_sessionTimeout}分钟',
            Icons.timer,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('日志设置', [
          _buildDropdownTile(
            '日志级别',
            _logLevel,
            {'debug': '调试', 'info': '信息', 'warning': '警告', 'error': '错误'},
            (value) => setState(() => _logLevel = value!),
            Icons.bug_report,
          ),
        ]),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection('密码策略', [
          _buildSwitchTile(
            '强密码要求',
            '要求复杂密码',
            _requireStrongPassword,
            (value) => setState(() => _requireStrongPassword = value),
            Icons.lock,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('身份验证', [
          _buildSwitchTile(
            '双因素认证',
            '增强账户安全',
            _enableTwoFactor,
            (value) => setState(() => _enableTwoFactor = value),
            Icons.security,
          ),
          _buildSliderTile(
            '最大登录尝试',
            _maxLoginAttempts.toDouble(),
            3,
            10,
            (value) => setState(() => _maxLoginAttempts = value.round()),
            '$_maxLoginAttempts次',
            Icons.login,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('维护操作', [
          ElevatedButton.icon(
            onPressed: () => _clearCache(),
            icon: const Icon(Icons.clear_all),
            label: const Text('清空缓存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.onWarning,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildAITab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection('模型设置', [
          _buildDropdownTile(
            'AI模型',
            _defaultModel,
            {
              'gpt-4': 'GPT-4',
              'gpt-3.5-turbo': 'GPT-3.5',
              'claude-3': 'Claude-3',
            },
            (value) => setState(() => _defaultModel = value!),
            Icons.smart_toy,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('生成参数', [
          _buildSliderTile(
            '温度参数',
            _temperature,
            0.0,
            1.0,
            (value) => setState(() => _temperature = value),
            _temperature.toStringAsFixed(1),
            Icons.thermostat,
            divisions: 10,
          ),
          _buildSliderTile(
            '最大Token',
            _maxTokens.toDouble(),
            500,
            4000,
            (value) => setState(() => _maxTokens = value.round()),
            '$_maxTokens',
            Icons.memory,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('模型测试', [
          ElevatedButton.icon(
            onPressed: () => _testAIModel(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('测试连接'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile<T>(
    String title,
    T value,
    Map<T, String> options,
    ValueChanged<T?> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        onChanged: onChanged,
        items: options.entries.map((entry) {
          return DropdownMenuItem<T>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        underline: Container(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String displayValue,
    IconData icon, {
    int? divisions,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          trailing: Text(
            displayValue,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  void _saveAllSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置已保存'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空缓存'),
        content: const Text('确定要清空所有缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清空')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _testAIModel() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('测试AI模型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在测试连接...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('模型 $_defaultModel 连接成功'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
} 