import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('推送通知'),
                  subtitle: const Text('接收应用通知消息'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('深色模式'),
                  subtitle: const Text('启用深色主题'),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
                ListTile(
                  title: const Text('退出登录'),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 