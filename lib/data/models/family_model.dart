import 'user_profile_model.dart';

/// Модель сімейної групи для спільних заощаджень.
class FamilyGroup {
  final String id;
  final String name;
  final String inviteCode;
  final List<FamilyMember> members;
  final List<String> sharedGoalIds;
  final DateTime createdAt;

  FamilyGroup({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.members,
    this.sharedGoalIds = const [],
    required this.createdAt,
  });

  factory FamilyGroup.fromJson(Map<String, dynamic> json) {
    return FamilyGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      sharedGoalIds: (json['sharedGoalIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'members': members.map((e) => e.toJson()).toList(),
      'sharedGoalIds': sharedGoalIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Модель учасника сімейної групи.
class FamilyMember {
  final String userId;
  final String name;
  final String avatarUrl;
  final FamilyRole role;
  final double totalContributed;

  FamilyMember({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.role,
    this.totalContributed = 0,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      userId: json['userId'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      role: FamilyRole.values.firstWhere((e) => e.name == json['role']),
      totalContributed: (json['totalContributed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'totalContributed': totalContributed,
    };
  }
}

/// Ролі в сімейній групі.
enum FamilyRole {
  admin,
  member,
  child;

  String get displayNameUA {
    switch (this) {
      case FamilyRole.admin: return 'Адмін';
      case FamilyRole.member: return 'Учасник';
      case FamilyRole.child: return 'Дитина';
    }
  }
}
