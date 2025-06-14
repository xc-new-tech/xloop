import 'package:equatable/equatable.dart';

/// 警报级别枚举
enum AlertLevel {
  info,
  warning,
  error,
  critical,
}

/// 警报状态枚举
enum AlertStatus {
  active,
  acknowledged,
  resolved,
}

/// 警报实体
class Alert extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertLevel level;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.status,
    required this.createdAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        level,
        status,
        createdAt,
        acknowledgedAt,
        resolvedAt,
        metadata,
      ];

  /// 复制并更新实体
  Alert copyWith({
    String? id,
    String? title,
    String? message,
    AlertLevel? level,
    AlertStatus? status,
    DateTime? createdAt,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 是否为严重警报
  bool get isCritical => level == AlertLevel.critical || level == AlertLevel.error;

  /// 是否已确认
  bool get isAcknowledged => status == AlertStatus.acknowledged;

  /// 是否已解决
  bool get isResolved => status == AlertStatus.resolved;

  /// 是否为活跃状态
  bool get isActive => status == AlertStatus.active;
} 