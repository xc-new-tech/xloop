import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 自定义按钮组件
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.icon,
    this.isOutlined = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final Widget? icon;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 48.h;
    final buttonBorderRadius = borderRadius ?? 8.r;
    
    if (isOutlined) {
      return _buildOutlinedButton(context, buttonHeight, buttonBorderRadius);
    } else {
      return _buildElevatedButton(context, buttonHeight, buttonBorderRadius);
    }
  }

  /// 构建填充按钮
  Widget _buildElevatedButton(
    BuildContext context,
    double buttonHeight,
    double buttonBorderRadius,
  ) {
    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: Theme.of(context).disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          elevation: 0,
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  /// 构建轮廓按钮
  Widget _buildOutlinedButton(
    BuildContext context,
    double buttonHeight,
    double buttonBorderRadius,
  ) {
    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? Theme.of(context).primaryColor,
          side: BorderSide(
            color: backgroundColor ?? Theme.of(context).primaryColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  /// 构建按钮内容
  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? Theme.of(context).primaryColor
                : Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: 8.w),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isOutlined
                  ? (textColor ?? Theme.of(context).primaryColor)
                  : (textColor ?? Colors.white),
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isOutlined
            ? (textColor ?? Theme.of(context).primaryColor)
            : (textColor ?? Colors.white),
      ),
    );
  }
} 