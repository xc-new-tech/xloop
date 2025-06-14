import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 密码强度等级
enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong,
}

/// 密码强度指示器组件
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = _calculatePasswordStrength(password);
    final strengthInfo = _getStrengthInfo(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 强度条
        Row(
          children: [
            Text(
              '密码强度：',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(child: _buildStrengthBar(context, strength)),
            SizedBox(width: 8.w),
            Text(
              strengthInfo.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: strengthInfo.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        // 密码要求提示
        _buildPasswordRequirements(context),
      ],
    );
  }

  /// 构建强度条
  Widget _buildStrengthBar(BuildContext context, PasswordStrength strength) {
    return Container(
      height: 4.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.r),
        color: Theme.of(context).dividerColor,
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index < strength.index + 1;
          final strengthInfo = _getStrengthInfo(strength);
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 2.w : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.r),
                color: isActive ? strengthInfo.color : Colors.transparent,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 构建密码要求提示
  Widget _buildPasswordRequirements(BuildContext context) {
    final requirements = [
      _PasswordRequirement(
        text: '至少8个字符',
        isValid: password.length >= 8,
      ),
      _PasswordRequirement(
        text: '包含大写字母',
        isValid: RegExp(r'[A-Z]').hasMatch(password),
      ),
      _PasswordRequirement(
        text: '包含小写字母',
        isValid: RegExp(r'[a-z]').hasMatch(password),
      ),
      _PasswordRequirement(
        text: '包含数字',
        isValid: RegExp(r'[0-9]').hasMatch(password),
      ),
      _PasswordRequirement(
        text: '包含特殊字符',
        isValid: RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>?]').hasMatch(password),
      ),
    ];

    return Wrap(
      spacing: 16.w,
      runSpacing: 4.h,
      children: requirements.map((requirement) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              requirement.isValid 
                  ? Icons.check_circle 
                  : Icons.radio_button_unchecked,
              size: 16.sp,
              color: requirement.isValid 
                  ? Colors.green 
                  : Theme.of(context).hintColor,
            ),
            SizedBox(width: 4.w),
            Text(
              requirement.text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: requirement.isValid 
                    ? Colors.green 
                    : Theme.of(context).hintColor,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// 计算密码强度
  PasswordStrength _calculatePasswordStrength(String password) {
    int score = 0;
    
    // 长度检查
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // 字符类型检查
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>?]').hasMatch(password)) score++;
    
    // 特殊模式检查
    if (password.length >= 16) score++;
    if (RegExp(r'[^\w\s]').hasMatch(password)) score++; // 其他特殊字符
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    if (score <= 6) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  /// 获取强度信息
  _PasswordStrengthInfo _getStrengthInfo(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return _PasswordStrengthInfo(
          label: '弱',
          color: Colors.red,
        );
      case PasswordStrength.medium:
        return _PasswordStrengthInfo(
          label: '中等',
          color: Colors.orange,
        );
      case PasswordStrength.strong:
        return _PasswordStrengthInfo(
          label: '强',
          color: Colors.blue,
        );
      case PasswordStrength.veryStrong:
        return _PasswordStrengthInfo(
          label: '很强',
          color: Colors.green,
        );
    }
  }
}

/// 密码强度信息
class _PasswordStrengthInfo {
  final String label;
  final Color color;

  _PasswordStrengthInfo({
    required this.label,
    required this.color,
  });
}

/// 密码要求
class _PasswordRequirement {
  final String text;
  final bool isValid;

  _PasswordRequirement({
    required this.text,
    required this.isValid,
  });
} 