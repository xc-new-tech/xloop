import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../presentation/bloc/permission_bloc.dart';
import '../presentation/bloc/permission_event.dart';
import '../presentation/bloc/permission_state.dart';
import '../presentation/widgets/permission_guard.dart';

/// 权限模块演示页面
class PermissionDemoPage extends StatelessWidget {
  const PermissionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PermissionBloc>(
      create: (context) => GetIt.instance<PermissionBloc>()
        ..add(LoadCurrentUserPermissions()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('权限模块演示'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '权限模块功能演示',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                
                // 权限状态显示
                _PermissionStatusCard(),
                SizedBox(height: 20),
                
                // 权限守卫演示
                Text(
                  '权限守卫演示',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                
                _PermissionGuardDemo(),
                SizedBox(height: 20),
                
                // 管理员权限演示
                _AdminGuardDemo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 权限状态显示卡片
class _PermissionStatusCard extends StatelessWidget {
  const _PermissionStatusCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前权限状态',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                if (state is PermissionLoading)
                  const Row(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 10),
                      Text('加载权限信息中...'),
                    ],
                  )
                else if (state is PermissionError)
                  Text(
                    '错误: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  )
                else if (state is PermissionLoaded)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('用户ID: ${state.currentUserPermissions?.userId ?? '未知'}'),
                      const SizedBox(height: 5),
                      Text('角色数量: ${state.currentUserPermissions?.roles.length ?? 0}'),
                      const SizedBox(height: 5),
                      Text('权限数量: ${state.permissions.length}'),
                      const SizedBox(height: 5),
                      Text('角色列表: ${state.roles.length}'),
                      const SizedBox(height: 10),
                      
                      if (state.currentUserPermissions?.roles.isNotEmpty == true) ...[
                        const Text(
                          '用户角色:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...state.currentUserPermissions!.roles.map(
                          (role) => Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text('• ${role.name} - ${role.description}'),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  const Text('未初始化'),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 权限守卫演示组件
class _PermissionGuardDemo extends StatelessWidget {
  const _PermissionGuardDemo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '权限守卫测试',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // 测试读取用户权限
            PermissionGuard(
              action: 'read',
              resource: 'users',
              fallback: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('❌ 没有读取用户权限'),
                  ],
                ),
              ),
              loading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('正在检查权限...'),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('✅ 有读取用户权限 - 可以看到这个内容'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 测试创建知识库权限
            PermissionGuard(
              action: 'create',
              resource: 'knowledge_bases',
              fallback: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('❌ 没有创建知识库权限'),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('✅ 有创建知识库权限'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 管理员权限守卫演示
class _AdminGuardDemo extends StatelessWidget {
  const _AdminGuardDemo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '管理员权限测试',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            AdminGuard(
              fallback: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.lock, color: Colors.grey, size: 32),
                    SizedBox(height: 8),
                    Text(
                      '🔒 您不是管理员',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text('无法访问管理功能'),
                  ],
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.admin_panel_settings, 
                         color: Colors.purple, size: 32),
                    SizedBox(height: 8),
                    Text(
                      '🎉 恭喜！您有管理员权限',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text('可以访问系统管理功能'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 