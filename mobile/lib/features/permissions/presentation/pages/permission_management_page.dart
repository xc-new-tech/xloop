import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../bloc/permission_bloc.dart';
import '../bloc/permission_event.dart';
import '../bloc/permission_state.dart';
import '../widgets/permission_guard.dart';

class PermissionManagementPage extends StatelessWidget {
  const PermissionManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PermissionBloc>(
      create: (context) => GetIt.instance<PermissionBloc>()
        ..add(LoadCurrentUserPermissions())
        ..add(LoadAllPermissions())
        ..add(LoadAllRoles()),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: '权限管理',
        ),
        body: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: '权限列表'),
                  Tab(text: '角色管理'),
                  Tab(text: '我的权限'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _PermissionsTab(),
                    _RolesTab(),
                    _MyPermissionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        if (state is PermissionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PermissionError) {
          return Center(child: Text('错误: ${state.message}'));
        }

        if (state is PermissionLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.permissions.length,
            itemBuilder: (context, index) {
              final permission = state.permissions[index];
              return Card(
                child: ListTile(
                  title: Text(permission.displayName),
                  subtitle: Text('${permission.module}.${permission.resource}.${permission.action}'),
                  trailing: Icon(
                    Icons.security,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('暂无权限数据'));
      },
    );
  }
}

class _RolesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        if (state is PermissionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PermissionError) {
          return Center(child: Text('错误: ${state.message}'));
        }

        if (state is PermissionLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.roles.length,
            itemBuilder: (context, index) {
              final role = state.roles[index];
              return Card(
                child: ListTile(
                  title: Text(role.name),
                  subtitle: Text(role.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text('${role.permissions.length} 权限'),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        role.isActive ? Icons.check_circle : Icons.cancel,
                        color: role.isActive ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('暂无角色数据'));
      },
    );
  }
}

class _MyPermissionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        if (state is PermissionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PermissionError) {
          return Center(child: Text('错误: ${state.message}'));
        }

        if (state is PermissionLoaded && state.currentUserPermissions != null) {
          final userPermissions = state.currentUserPermissions!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '用户ID: ${userPermissions.userId}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '角色数量: ${userPermissions.roles.length}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '权限数量: ${userPermissions.allPermissions.length}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 权限演示
                Text(
                  '权限控制演示',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                
                const SizedBox(height: 16),
                
                // 管理员权限演示
                AdminGuard(
                  fallback: Card(
                    color: Colors.red.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.red),
                          SizedBox(width: 8),
                          Text('您没有管理员权限'),
                        ],
                      ),
                    ),
                  ),
                  child: Card(
                    color: Colors.green.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.green),
                          SizedBox(width: 8),
                          Text('您拥有管理员权限'),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 权限检查演示
                PermissionGuard(
                  action: 'read',
                  resource: 'users',
                  fallback: Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.visibility_off, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('您无法查看用户列表'),
                        ],
                      ),
                    ),
                  ),
                  child: Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('您可以查看用户列表'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('正在加载用户权限...'));
      },
    );
  }
} 