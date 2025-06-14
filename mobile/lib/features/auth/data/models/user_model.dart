import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// 用户数据模型类，用于JSON序列化和反序列化
@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.firstName,
    super.lastName,
    super.avatar,
    required super.role,
    required super.status,
    required super.isEmailVerified,
    required super.createdAt,
    required super.updatedAt,
    super.profile,
    super.preferences,
  });

  /// 从JSON创建UserModel实例
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// 从User实体创建UserModel
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatar: user.avatar,
      role: user.role,
      status: user.status,
      isEmailVerified: user.isEmailVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      profile: user.profile,
      preferences: user.preferences,
    );
  }

  /// 转换为User实体
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
      role: role,
      status: status,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profile: profile,
      preferences: preferences,
    );
  }

  /// 复制并更新UserModel
  @override
  UserModel copyWith({
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
    return UserModel(
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
  String toString() {
    return 'UserModel('
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