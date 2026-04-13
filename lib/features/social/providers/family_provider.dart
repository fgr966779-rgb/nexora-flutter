import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/family_model.dart';

final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyGroup?>((ref) {
  return FamilyNotifier();
});

class FamilyNotifier extends StateNotifier<FamilyGroup?> {
  FamilyNotifier() : super(null);

  void createGroup(String name) {
    state = FamilyGroup(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      inviteCode: 'NEX-1234',
      members: [
        FamilyMember(
          userId: 'u_1',
          name: 'Ти',
          avatarUrl: '',
          role: FamilyRole.admin,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  void joinGroup(String code) {
    // Mock joining
    state = FamilyGroup(
      id: 'f_joined',
      name: 'Наша Сім\'я',
      inviteCode: code,
      members: [
        FamilyMember(userId: 'u_2', name: 'Олена', avatarUrl: '', role: FamilyRole.admin),
        FamilyMember(userId: 'u_1', name: 'Ти', avatarUrl: '', role: FamilyRole.member),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  void addMember(String name, FamilyRole role) {
    if (state == null) return;
    final newMember = FamilyMember(
      userId: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      avatarUrl: '',
      role: role,
    );
    state = FamilyGroup(
      id: state!.id,
      name: state!.name,
      inviteCode: state!.inviteCode,
      members: [...state!.members, newMember],
      sharedGoalIds: state!.sharedGoalIds,
      createdAt: state!.createdAt,
    );
  }

  void leaveGroup() {
    state = null;
  }
}
