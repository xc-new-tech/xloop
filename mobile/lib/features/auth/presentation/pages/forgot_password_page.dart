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
import '../widgets/auth_footer.dart';

/// 忘记密码页面
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _emailSent = false;
  String _submittedEmail = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('忘记密码'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            // 密码重置邮件发送成功
            setState(() {
              _emailSent = true;
              _submittedEmail = state.email;
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
            loadingText: '正在发送重置邮件...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 32.h),
                    
                    // 页面头部
                    AuthHeader(
                      title: _emailSent ? '邮件已发送' : '重置密码',
                      subtitle: _emailSent 
                          ? '请检查您的邮箱并按照说明操作'
                          : '输入您的邮箱地址，我们将发送重置链接',
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    if (_emailSent) ...[
                      // 邮件发送成功界面
                      _buildEmailSentContent(),
                    ] else ...[
                      // 邮箱输入界面
                      _buildEmailInputContent(state),
                    ],
                    
                    SizedBox(height: 32.h),
                    
                    // 页面底部
                    AuthFooter(
                      text: '想起密码了？',
                      actionText: '返回登录',
                      onActionTap: () {
                        Navigator.of(context).pushReplacementNamed(RouteConstants.login);
                      },
                    ),
                    
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

  /// 构建邮件发送成功内容
  Widget _buildEmailSentContent() {
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
            Icons.email_outlined,
            size: 40.sp,
            color: Colors.green,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        // 成功消息
        Text(
          '重置链接已发送到：',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          _submittedEmail,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 24.h),
        
        // 提示信息
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
                    Icons.info_outline,
                    size: 20.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '注意事项',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '• 请检查您的收件箱和垃圾邮件文件夹\n'
                '• 重置链接有效期为24小时\n'
                '• 如果未收到邮件，请等待几分钟后重试',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 32.h),
        
        // 重新发送按钮
        OutlinedButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text('重新发送'),
        ),
      ],
    );
  }

  /// 构建邮箱输入内容
  Widget _buildEmailInputContent(AuthState state) {
    return Column(
      children: [
        // 邮箱输入表单
        FormBuilder(
          key: _formKey,
          child: CustomTextField(
            name: 'email',
            label: '邮箱地址',
            hintText: '请输入您注册时使用的邮箱地址',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validators: [
              FormBuilderValidators.required(errorText: '请输入邮箱地址'),
              FormBuilderValidators.email(errorText: '请输入有效的邮箱地址'),
              FormBuilderValidators.maxLength(
                AppConstants.maxEmailLength,
                errorText: '邮箱长度不能超过${AppConstants.maxEmailLength}位',
              ),
            ],
          ),
        ),
        
        SizedBox(height: 32.h),
        
        // 发送重置邮件按钮
        CustomButton(
          text: '发送重置邮件',
          onPressed: state is AuthLoading ? null : _handleSendResetEmail,
          isLoading: state is AuthLoading,
        ),
        
        SizedBox(height: 24.h),
        
        // 提示信息
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
                         color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security_outlined,
                size: 20.sp,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '我们将向您的邮箱发送一个安全重置链接，点击链接即可重置密码。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 处理发送重置邮件
  void _handleSendResetEmail() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final email = formData['email'] as String;
      
      context.read<AuthBloc>().add(
        AuthPasswordResetRequested(email: email),
      );
    }
  }
} 