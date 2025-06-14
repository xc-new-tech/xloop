import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 通用加载组件
/// 提供多种加载样式和配置选项
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final LoadingType type;
  final bool overlay;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 24.0,
    this.type = LoadingType.circular,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget loading = _buildLoadingIndicator();

    if (overlay) {
      return Material(
        color: Colors.black54,
        child: Center(child: loading),
      );
    }

    return loading;
  }

  Widget _buildLoadingIndicator() {
    Widget indicator;

    switch (type) {
      case LoadingType.circular:
        indicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: color ?? AppColors.primary,
          ),
        );
        break;
      case LoadingType.linear:
        indicator = SizedBox(
          width: size * 4,
          child: LinearProgressIndicator(
            color: color ?? AppColors.primary,
            backgroundColor: AppColors.surfaceVariant,
          ),
        );
        break;
      case LoadingType.dots:
        indicator = _DotsLoadingIndicator(
          color: color ?? AppColors.primary,
          size: size,
        );
        break;
      case LoadingType.pulse:
        indicator = _PulseLoadingIndicator(
          color: color ?? AppColors.primary,
          size: size,
        );
        break;
      case LoadingType.spinner:
        indicator = _SpinnerLoadingIndicator(
          color: color ?? AppColors.primary,
          size: size,
        );
        break;
    }

    if (message != null) {
      return Card(
        elevation: 8.0,
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return indicator;
  }

  /// 创建覆盖层加载组件
  factory LoadingWidget.overlay({
    String? message,
    Color? color,
    double size = 32.0,
    LoadingType type = LoadingType.circular,
  }) {
    return LoadingWidget(
      message: message,
      color: color,
      size: size,
      type: type,
      overlay: true,
    );
  }

  /// 创建小型加载组件
  factory LoadingWidget.small({
    Color? color,
    LoadingType type = LoadingType.circular,
  }) {
    return LoadingWidget(
      color: color,
      size: 16.0,
      type: type,
    );
  }

  /// 创建大型加载组件
  factory LoadingWidget.large({
    String? message,
    Color? color,
    LoadingType type = LoadingType.circular,
  }) {
    return LoadingWidget(
      message: message,
      color: color,
      size: 48.0,
      type: type,
    );
  }
}

/// 加载类型枚举
enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
  spinner,
}

/// 点状加载指示器
class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animationValue = (_controller.value * 3 - index).clamp(0.0, 1.0);
              final scale = 0.5 + 0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 脉冲加载指示器
class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// 旋转器加载指示器
class _SpinnerLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _SpinnerLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_SpinnerLoadingIndicator> createState() => _SpinnerLoadingIndicatorState();
}

class _SpinnerLoadingIndicatorState extends State<_SpinnerLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinnerPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpinnerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // 绘制背景圆
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制进度弧
    const sweepAngle = 1.5; // 90度
    final startAngle = progress * 2 * 3.14159;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 