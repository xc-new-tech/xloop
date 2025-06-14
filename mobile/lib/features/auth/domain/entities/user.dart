import 'package:equatable/equatable.dart';

/// 用户实体类
class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String role;
  final String status;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? preferences;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    required this.role,
    required this.status,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    this.preferences,
  });

  /// 获取用户全名
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }

  /// 获取用户显示名称
  String get displayName => fullName.isNotEmpty ? fullName : username;

  /// 检查是否为管理员
  bool get isAdmin => role == 'admin';

  /// 检查账户是否活跃
  bool get isActive => status == 'active';

  /// 检查账户是否被禁用
  bool get isDisabled => status == 'disabled';

  /// 检查账户是否待激活
  bool get isPending => status == 'pending';

  /// 复制并更新用户信息
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? role,
    String? status,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      status: status ?? this.status,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        avatar,
        role,
        status,
        isEmailVerified,
        createdAt,
        updatedAt,
        profile,
        preferences,
      ];

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'username: $username, '
        'email: $email, '
        'fullName: $fullName, '
        'role: $role, '
        'status: $status, '
        'isEmailVerified: $isEmailVerified'
        ')';
  }
} 