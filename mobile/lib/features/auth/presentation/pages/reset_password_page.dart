import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/password_strength_indicator.dart';

/// 重置密码页面
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.token,
    this.email,
  });

  final String token;
  final String? email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _currentPassword = '';
  bool _resetSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('重置密码'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: !_resetSuccess,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSuccess) {
            // 密码重置成功
            setState(() {
              _resetSuccess = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthError) {
            // 显示错误消息
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            loadingText: '正在重置密码...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 32.h),
                    
                    // 页面头部
                    AuthHeader(
                      title: _resetSuccess ? '重置成功' : '设置新密码',
                      subtitle: _resetSuccess 
                          ? '您的密码已成功重置'
                          : '请设置一个安全的新密码',
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    if (_resetSuccess) ...[
                      // 重置成功界面
                      _buildSuccessContent(),
                    ] else ...[
                      // 密码重置界面
                      _buildPasswordResetContent(state),
                    ],
                    
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建重置成功内容
  Widget _buildSuccessContent() {
    return Column(
      children: [
        // 成功图标
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 40.sp,
            color: Colors.green,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        // 成功消息
        Text(
          '密码重置成功！',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 16.h),
        
        Text(
          '您的密码已更新，现在可以使用新密码登录了。',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 32.h),
        
        // 去登录按钮
        CustomButton(
          text: '去登录',
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteConstants.login,
              (route) => false,
            );
          },
        ),
        
        SizedBox(height: 24.h),
        
        // 安全提示
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_outlined,
                    size: 20.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '安全提示',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '• 请妥善保管您的新密码\n'
                '• 建议定期更换密码\n'
                '• 不要与他人分享您的账户信息',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建密码重置内容
  Widget _buildPasswordResetContent(AuthState state) {
    return Column(
      children: [
        // 邮箱显示（如果有）
        if (widget.email != null) ...[
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 20.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '重置账户',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Text(
                        widget.email!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
        ],
        
        // 密码重置表单
        _buildPasswordResetForm(),
        
        SizedBox(height: 24.h),
        
        // 密码强度指示器
        PasswordStrengthIndicator(password: _currentPassword),
        
        SizedBox(height: 32.h),
        
        // 重置密码按钮
        CustomButton(
          text: '重置密码',
          onPressed: state is AuthLoading ? null : _handleResetPassword,
          isLoading: state is AuthLoading,
        ),
      ],
    );
  }

  /// 构建密码重置表单
  Widget _buildPasswordResetForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          // 新密码输入框
          CustomTextField(
            name: 'password',
            label: '新密码',
            hintText: '请输入新密码',
            obscureText: !_isPasswordVisible,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            validators: [
              FormBuilderValidators.required(errorText: '请输入新密码'),
              FormBuilderValidators.minLength(
                AppConstants.minPasswordLength,
                errorText: '密码长度不能少于${AppConstants.minPasswordLength}位',
              ),
              FormBuilderValidators.maxLength(
                AppConstants.maxPasswordLength,
                errorText: '密码长度不能超过${AppConstants.maxPasswordLength}位',
              ),
              _passwordComplexityValidator,
            ],
            onChanged: (value) {
              setState(() {
                _currentPassword = value ?? '';
              });
            },
          ),
          
          SizedBox(height: 16.h),
          
          // 确认密码输入框
          CustomTextField(
            name: 'confirmPassword',
            label: '确认新密码',
            hintText: '请再次输入新密码',
            obscureText: !_isConfirmPasswordVisible,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            validators: [
              FormBuilderValidators.required(errorText: '请确认新密码'),
              (value) {
                final password = _formKey.currentState?.fields['password']?.value;
                if (value != password) {
                  return '两次输入的密码不一致';
                }
                return null;
              },
            ],
          ),
        ],
      ),
    );
  }

  /// 密码复杂度验证器
  String? _passwordComplexityValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    
    // 检查是否包含大写字母
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return '密码必须包含至少一个大写字母';
    }
    
    // 检查是否包含小写字母
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return '密码必须包含至少一个小写字母';
    }
    
    // 检查是否包含数字
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return '密码必须包含至少一个数字';
    }
    
    // 检查是否包含特殊字符
    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>?]').hasMatch(value)) {
      return '密码必须包含至少一个特殊字符';
    }
    
    return null;
  }

  /// 处理重置密码
  void _handleResetPassword() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      context.read<AuthBloc>().add(
        AuthResetPassword(
          token: widget.token,
          newPassword: formData['password'] as String,
          confirmPassword: formData['confirmPassword'] as String,
        ),
      );
    }
  }
} 