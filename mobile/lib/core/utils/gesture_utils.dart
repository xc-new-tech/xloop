import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 手势操作工具类
class GestureUtils {
  GestureUtils._();

  /// 触觉反馈类型
  static void hapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// 创建可点击区域（确保最小触摸目标）
  static Widget createTouchTarget({
    required Widget child,
    required VoidCallback onTap,
    double minSize = 44.0,
    HapticFeedbackType? hapticFeedback,
    BorderRadius? borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (hapticFeedback != null) {
            GestureUtils.hapticFeedback(hapticFeedback);
          }
          onTap();
        },
        borderRadius: borderRadius,
        child: Container(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          child: child,
        ),
      ),
    );
  }

  /// 创建长按手势检测器
  static Widget createLongPressDetector({
    required Widget child,
    required VoidCallback onLongPress,
    VoidCallback? onTap,
    Duration longPressDuration = const Duration(milliseconds: 500),
    HapticFeedbackType hapticFeedback = HapticFeedbackType.medium,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        GestureUtils.hapticFeedback(hapticFeedback);
        onLongPress();
      },
      child: child,
    );
  }

  /// 创建双击手势检测器
  static Widget createDoubleTapDetector({
    required Widget child,
    required VoidCallback onDoubleTap,
    VoidCallback? onTap,
    HapticFeedbackType hapticFeedback = HapticFeedbackType.light,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: () {
        GestureUtils.hapticFeedback(hapticFeedback);
        onDoubleTap();
      },
      child: child,
    );
  }

  /// 创建滑动手势检测器
  static Widget createSwipeDetector({
    required Widget child,
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    VoidCallback? onSwipeUp,
    VoidCallback? onSwipeDown,
    double sensitivity = 100.0,
    HapticFeedbackType hapticFeedback = HapticFeedbackType.light,
  }) {
    return GestureDetector(
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        
        if (velocity.dx.abs() > velocity.dy.abs()) {
          // 水平滑动
          if (velocity.dx > sensitivity && onSwipeRight != null) {
            GestureUtils.hapticFeedback(hapticFeedback);
            onSwipeRight();
          } else if (velocity.dx < -sensitivity && onSwipeLeft != null) {
            GestureUtils.hapticFeedback(hapticFeedback);
            onSwipeLeft();
          }
        } else {
          // 垂直滑动
          if (velocity.dy > sensitivity && onSwipeDown != null) {
            GestureUtils.hapticFeedback(hapticFeedback);
            onSwipeDown();
          } else if (velocity.dy < -sensitivity && onSwipeUp != null) {
            GestureUtils.hapticFeedback(hapticFeedback);
            onSwipeUp();
          }
        }
      },
      child: child,
    );
  }

  /// 创建缩放手势检测器
  static Widget createScaleDetector({
    required Widget child,
    required Function(double scale) onScaleUpdate,
    VoidCallback? onScaleStart,
    VoidCallback? onScaleEnd,
    double minScale = 0.5,
    double maxScale = 3.0,
  }) {
    return GestureDetector(
      onScaleStart: (details) {
        onScaleStart?.call();
      },
      onScaleUpdate: (details) {
        final scale = details.scale.clamp(minScale, maxScale);
        onScaleUpdate(scale);
      },
      onScaleEnd: (details) {
        onScaleEnd?.call();
      },
      child: child,
    );
  }

  /// 创建拖拽手势检测器
  static Widget createDragDetector({
    required Widget child,
    required Function(Offset delta) onDragUpdate,
    VoidCallback? onDragStart,
    VoidCallback? onDragEnd,
    Axis? axis,
    HapticFeedbackType hapticFeedback = HapticFeedbackType.light,
  }) {
    return GestureDetector(
      onPanStart: (details) {
        GestureUtils.hapticFeedback(hapticFeedback);
        onDragStart?.call();
      },
      onPanUpdate: (details) {
        Offset delta = details.delta;
        
        // 限制拖拽方向
        if (axis == Axis.horizontal) {
          delta = Offset(delta.dx, 0);
        } else if (axis == Axis.vertical) {
          delta = Offset(0, delta.dy);
        }
        
        onDragUpdate(delta);
      },
      onPanEnd: (details) {
        onDragEnd?.call();
      },
      child: child,
    );
  }

  /// 创建多点触控手势检测器
  static Widget createMultiTouchDetector({
    required Widget child,
    Function(int pointerCount)? onPointerCountChanged,
    Function(List<Offset> positions)? onMultiTouchUpdate,
  }) {
    final Set<int> _activePointers = <int>{};
    
    return Listener(
      onPointerDown: (event) {
        _activePointers.add(event.pointer);
        onPointerCountChanged?.call(_activePointers.length);
      },
      onPointerUp: (event) {
        _activePointers.remove(event.pointer);
        onPointerCountChanged?.call(_activePointers.length);
      },
      onPointerCancel: (event) {
        _activePointers.remove(event.pointer);
        onPointerCountChanged?.call(_activePointers.length);
      },
      child: child,
    );
  }

  /// 创建边缘滑动检测器
  static Widget createEdgeSwipeDetector({
    required Widget child,
    VoidCallback? onLeftEdgeSwipe,
    VoidCallback? onRightEdgeSwipe,
    VoidCallback? onTopEdgeSwipe,
    VoidCallback? onBottomEdgeSwipe,
    double edgeThreshold = 50.0,
    HapticFeedbackType hapticFeedback = HapticFeedbackType.medium,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            final position = details.localPosition;
            final size = constraints.biggest;
            
            // 检测边缘滑动
            if (position.dx < edgeThreshold && onLeftEdgeSwipe != null) {
              GestureUtils.hapticFeedback(hapticFeedback);
              onLeftEdgeSwipe();
            } else if (position.dx > size.width - edgeThreshold && onRightEdgeSwipe != null) {
              GestureUtils.hapticFeedback(hapticFeedback);
              onRightEdgeSwipe();
            } else if (position.dy < edgeThreshold && onTopEdgeSwipe != null) {
              GestureUtils.hapticFeedback(hapticFeedback);
              onTopEdgeSwipe();
            } else if (position.dy > size.height - edgeThreshold && onBottomEdgeSwipe != null) {
              GestureUtils.hapticFeedback(hapticFeedback);
              onBottomEdgeSwipe();
            }
          },
          child: child,
        );
      },
    );
  }

  /// 创建旋转手势检测器
  static Widget createRotationDetector({
    required Widget child,
    required Function(double angle) onRotationUpdate,
    VoidCallback? onRotationStart,
    VoidCallback? onRotationEnd,
  }) {
    return GestureDetector(
      onScaleStart: (details) {
        onRotationStart?.call();
      },
      onScaleUpdate: (details) {
        onRotationUpdate(details.rotation);
      },
      onScaleEnd: (details) {
        onRotationEnd?.call();
      },
      child: child,
    );
  }

  /// 创建力度感应检测器（3D Touch / Force Touch）
  static Widget createForceDetector({
    required Widget child,
    Function(double force)? onForceChanged,
    VoidCallback? onForceStart,
    VoidCallback? onForceEnd,
    double forceThreshold = 0.5,
  }) {
    return Listener(
      onPointerDown: (event) {
        if (event.pressure > forceThreshold) {
          onForceStart?.call();
        }
      },
      onPointerMove: (event) {
        onForceChanged?.call(event.pressure);
      },
      onPointerUp: (event) {
        onForceEnd?.call();
      },
      child: child,
    );
  }

  /// 创建可取消的手势检测器
  static Widget createCancellableGestureDetector({
    required Widget child,
    required VoidCallback onTap,
    Duration cancelDuration = const Duration(milliseconds: 200),
    HapticFeedbackType hapticFeedback = HapticFeedbackType.light,
  }) {
    bool _isCancelled = false;
    
    return GestureDetector(
      onTapDown: (details) {
        _isCancelled = false;
        GestureUtils.hapticFeedback(hapticFeedback);
      },
      onTapCancel: () {
        _isCancelled = true;
      },
      onTap: () {
        if (!_isCancelled) {
          onTap();
        }
      },
      child: child,
    );
  }

  /// 创建延迟手势检测器
  static Widget createDelayedGestureDetector({
    required Widget child,
    required VoidCallback onTap,
    Duration delay = const Duration(milliseconds: 300),
    HapticFeedbackType hapticFeedback = HapticFeedbackType.light,
  }) {
    return GestureDetector(
      onTap: () {
        GestureUtils.hapticFeedback(hapticFeedback);
        Future.delayed(delay, onTap);
      },
      child: child,
    );
  }

  /// 创建防抖动手势检测器
  static Widget createDebounceGestureDetector({
    required Widget child,
    required VoidCallback onTap,
    Duration debounceDuration = const Duration(milliseconds: 500),
    HapticFeedbackType hapticFeedback = HapticFeedbackType.light,
  }) {
    DateTime? _lastTapTime;
    
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        if (_lastTapTime == null || 
            now.difference(_lastTapTime!) > debounceDuration) {
          _lastTapTime = now;
          GestureUtils.hapticFeedback(hapticFeedback);
          onTap();
        }
      },
      child: child,
    );
  }

  /// 获取手势方向
  static SwipeDirection getSwipeDirection(Offset velocity) {
    if (velocity.dx.abs() > velocity.dy.abs()) {
      return velocity.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return velocity.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }
  }

  /// 计算两点之间的距离
  static double calculateDistance(Offset point1, Offset point2) {
    return (point1 - point2).distance;
  }

  /// 计算两点之间的角度
  static double calculateAngle(Offset point1, Offset point2) {
    final delta = point2 - point1;
    return delta.direction;
  }

  /// 判断是否为有效的滑动手势
  static bool isValidSwipe(Offset velocity, double threshold) {
    return velocity.distance > threshold;
  }

  /// 创建自定义手势识别器
  static Widget createCustomGestureDetector({
    required Widget child,
    Map<Type, GestureRecognizerFactory>? gestures,
  }) {
    return RawGestureDetector(
      gestures: gestures ?? {},
      child: child,
    );
  }
}

/// 触觉反馈类型
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// 滑动方向
enum SwipeDirection {
  up,
  down,
  left,
  right,
}

/// 手势状态
enum GestureState {
  idle,
  started,
  updated,
  ended,
  cancelled,
}

/// 手势信息类
class GestureInfo {
  final GestureState state;
  final Offset? position;
  final Offset? velocity;
  final double? scale;
  final double? rotation;
  final DateTime timestamp;

  const GestureInfo({
    required this.state,
    this.position,
    this.velocity,
    this.scale,
    this.rotation,
    required this.timestamp,
  });

  GestureInfo copyWith({
    GestureState? state,
    Offset? position,
    Offset? velocity,
    double? scale,
    double? rotation,
    DateTime? timestamp,
  }) {
    return GestureInfo(
      state: state ?? this.state,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// 手势配置类
class GestureConfig {
  final double tapTimeout;
  final double doubleTapTimeout;
  final double longPressTimeout;
  final double swipeThreshold;
  final double scaleThreshold;
  final double rotationThreshold;
  final bool enableHapticFeedback;

  const GestureConfig({
    this.tapTimeout = 300.0,
    this.doubleTapTimeout = 300.0,
    this.longPressTimeout = 500.0,
    this.swipeThreshold = 100.0,
    this.scaleThreshold = 0.1,
    this.rotationThreshold = 0.1,
    this.enableHapticFeedback = true,
  });
} 