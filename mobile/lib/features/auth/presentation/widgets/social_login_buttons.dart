import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 社交登录按钮组件
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 微信登录
        _buildSocialButton(
          context: context,
          icon: Icons.wechat,
          text: '使用微信登录',
          color: const Color(0xFF07C160),
          onTap: () => _handleWeChatLogin(context),
        ),
        
        SizedBox(height: 12.h),
        
        // QQ登录
        _buildSocialButton(
          context: context,
          icon: Icons.message,
          text: '使用QQ登录',
          color: const Color(0xFF12B7F5),
          onTap: () => _handleQQLogin(context),
        ),
        
        SizedBox(height: 12.h),
        
        // Apple登录（仅在iOS平台显示）
        _buildSocialButton(
          context: context,
          icon: Icons.apple,
          text: '使用Apple登录',
          color: Colors.black,
          onTap: () => _handleAppleLogin(context),
        ),
      ],
    );
  }

  /// 构建社交登录按钮
  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: color,
          size: 20.sp,
        ),
        label: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  /// 处理微信登录
  void _handleWeChatLogin(BuildContext context) {
    // TODO: 实现微信登录
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('微信登录功能即将上线')),
    );
  }

  /// 处理QQ登录
  void _handleQQLogin(BuildContext context) {
    // TODO: 实现QQ登录
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QQ登录功能即将上线')),
    );
  }

  /// 处理Apple登录
  void _handleAppleLogin(BuildContext context) {
    // TODO: 实现Apple登录
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple登录功能即将上线')),
    );
  }
} 