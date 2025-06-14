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
import '../widgets/social_login_buttons.dart';
import '../widgets/auth_footer.dart';

/// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            // 登录成功，导航到主页
            Navigator.of(context).pushReplacementNamed(RouteConstants.home);
          } else if (state is AuthLoginFailure) {
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
            isLoading: state is AuthLoginLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.h),
                    
                    // 页面头部
                    const AuthHeader(
                      title: '欢迎回来',
                      subtitle: '请登录您的账户',
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // 登录表单
                    _buildLoginForm(),
                    
                    SizedBox(height: 24.h),
                    
                    // 忘记密码链接
                    _buildForgotPasswordLink(),
                    
                    SizedBox(height: 32.h),
                    
                    // 登录按钮
                    _buildLoginButton(state),
                    
                    SizedBox(height: 24.h),
                    
                    // 分割线
                    _buildDivider(),
                    
                    SizedBox(height: 24.h),
                    
                    // 社交登录按钮
                    const SocialLoginButtons(),
                    
                    SizedBox(height: 32.h),
                    
                    // 页面底部
                    AuthFooter(
                      text: '还没有账户？',
                      actionText: '立即注册',
                      onActionTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.register);
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

  /// 构建登录表单
  Widget _buildLoginForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          // 邮箱输入框
          CustomTextField(
            name: 'email',
            label: '邮箱地址',
            hintText: '请输入您的邮箱地址',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validators: [
              FormBuilderValidators.required(errorText: '请输入邮箱地址'),
              FormBuilderValidators.email(errorText: '请输入有效的邮箱地址'),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 密码输入框
          CustomTextField(
            name: 'password',
            label: '密码',
            hintText: '请输入您的密码',
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
              FormBuilderValidators.required(errorText: '请输入密码'),
              FormBuilderValidators.minLength(
                AppConstants.minPasswordLength,
                errorText: '密码长度不能少于${AppConstants.minPasswordLength}位',
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 记住我选项
          _buildRememberMeCheckbox(),
        ],
      ),
    );
  }

  /// 构建记住我选项
  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Text(
            '记住我',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  /// 构建忘记密码链接
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RouteConstants.forgotPassword);
        },
        child: Text(
          '忘记密码？',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 构建登录按钮
  Widget _buildLoginButton(AuthState state) {
    return CustomButton(
      text: '登录',
      onPressed: state is AuthLoginLoading ? null : _handleLogin,
      isLoading: state is AuthLoginLoading,
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '或者',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  /// 处理登录逻辑
  void _handleLogin() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: formData['email'] as String,
          password: formData['password'] as String,
          rememberMe: _rememberMe,
        ),
      );
    }
  }
} 