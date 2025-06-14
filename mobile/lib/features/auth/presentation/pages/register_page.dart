import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
import '../widgets/password_strength_indicator.dart';
import '../widgets/terms_agreement_checkbox.dart';

/// 注册页面
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  String _currentPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            // 注册成功，显示提示并导航到登录页面
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // 使用GoRouter导航到登录页面
            context.pushReplacementNamed('login');
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
            loadingText: '正在注册...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.h),
                    
                    // 页面头部
                    const AuthHeader(
                      title: '创建账户',
                      subtitle: '开始您的XLoop智能知识之旅',
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // 注册表单
                    _buildRegisterForm(),
                    
                    SizedBox(height: 24.h),
                    
                    // 密码强度指示器
                    PasswordStrengthIndicator(password: _currentPassword),
                    
                    SizedBox(height: 24.h),
                    
                    // 用户协议确认
                    TermsAgreementCheckbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // 注册按钮
                    _buildRegisterButton(state),
                    
                    SizedBox(height: 24.h),
                    
                    // 分割线
                    _buildDivider(),
                    
                    SizedBox(height: 24.h),
                    
                    // 社交登录按钮
                    const SocialLoginButtons(),
                    
                    SizedBox(height: 32.h),
                    
                    // 页面底部
                    AuthFooter(
                      text: '已有账户？',
                      actionText: '立即登录',
                      onActionTap: () {
                        context.go('/login');
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

  /// 构建注册表单
  Widget _buildRegisterForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          // 用户名输入框
          CustomTextField(
            name: 'username',
            label: '用户名',
            hintText: '请输入用户名',
            prefixIcon: const Icon(Icons.person_outlined),
            validators: [
              FormBuilderValidators.required(errorText: '请输入用户名'),
              FormBuilderValidators.minLength(
                3,
                errorText: '用户名长度不能少于3位',
              ),
              FormBuilderValidators.maxLength(
                AppConstants.maxUsernameLength,
                errorText: '用户名长度不能超过${AppConstants.maxUsernameLength}位',
              ),
              (value) {
                if (value == null || value.isEmpty) return null;
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return '用户名只能包含字母、数字和下划线';
                }
                return null;
              },
            ],
          ),
          
          SizedBox(height: 16.h),
          
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
              FormBuilderValidators.maxLength(
                AppConstants.maxEmailLength,
                errorText: '邮箱长度不能超过${AppConstants.maxEmailLength}位',
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 姓名输入框（可选）
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'firstName',
                  label: '名字',
                  hintText: '请输入名字（可选）',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  validators: [
                    FormBuilderValidators.maxLength(50, errorText: '名字长度不能超过50位'),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomTextField(
                  name: 'lastName',
                  label: '姓氏',
                  hintText: '请输入姓氏（可选）',
                  prefixIcon: const Icon(Icons.family_restroom_outlined),
                  validators: [
                    FormBuilderValidators.maxLength(50, errorText: '姓氏长度不能超过50位'),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 密码输入框
          CustomTextField(
            name: 'password',
            label: '密码',
            hintText: '请设置您的密码',
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
            label: '确认密码',
            hintText: '请再次输入密码',
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
              FormBuilderValidators.required(errorText: '请确认密码'),
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

  /// 构建注册按钮
  Widget _buildRegisterButton(AuthState state) {
    return CustomButton(
      text: '注册',
      onPressed: (state is AuthLoading || !_agreeToTerms) ? null : _handleRegister,
      isLoading: state is AuthLoading,
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

  /// 处理注册逻辑
  void _handleRegister() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请同意用户协议和隐私政策')),
        );
        return;
      }

      final formData = _formKey.currentState!.value;
      
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          username: formData['username'] as String,
          email: formData['email'] as String,
          password: formData['password'] as String,
          confirmPassword: formData['confirmPassword'] as String,
          firstName: formData['firstName'] as String?,
          lastName: formData['lastName'] as String?,
          agreeToTerms: _agreeToTerms,
        ),
      );
    }
  }
} 