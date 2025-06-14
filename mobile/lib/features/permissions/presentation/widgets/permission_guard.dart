import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/permission_bloc.dart';
import '../bloc/permission_event.dart';
import '../bloc/permission_state.dart';

/// 权限守卫组件
class PermissionGuard extends StatefulWidget {
  final Widget child;
  final String action;
  final String resource;
  final String? userId;
  final Widget? fallback;
  final Widget? loading;

  const PermissionGuard({
    super.key,
    required this.child,
    required this.action,
    required this.resource,
    this.userId,
    this.fallback,
    this.loading,
  });

  @override
  State<PermissionGuard> createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard> {
  @override
  void initState() {
    super.initState();
    // 检查权限
    context.read<PermissionBloc>().add(CheckPermissionEvent(
      action: widget.action,
      resource: widget.resource,
      userId: widget.userId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        if (state is PermissionLoading) {
          return widget.loading ?? const SizedBox.shrink();
        }

        if (state is PermissionError) {
          return widget.fallback ?? const SizedBox.shrink();
        }

        if (state is PermissionLoaded) {
          final hasPermission = state.hasPermission(widget.action, widget.resource);
          
          if (hasPermission) {
            return widget.child;
          } else {
            return widget.fallback ?? const SizedBox.shrink();
          }
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// 管理员权限守卫
class AdminGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      action: 'admin',
      resource: 'system',
      fallback: fallback,
      child: child,
    );
  }
} 