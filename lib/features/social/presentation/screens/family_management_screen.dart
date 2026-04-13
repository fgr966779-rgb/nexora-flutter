import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora/core/constants/app_colors.dart';
import 'package:nexora/core/constants/app_spacing.dart';
import 'package:nexora/core/constants/app_typography.dart';
import 'package:nexora/core/constants/app_radii.dart';
import 'package:nexora/core/extensions/build_context_ext.dart';
import 'package:nexora/features/social/providers/family_provider.dart';
import 'package:nexora/data/models/family_model.dart';

class FamilyManagementScreen extends ConsumerWidget {
  const FamilyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyProvider);
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Сім\'я'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: family == null
            ? _buildNoFamily(context, ref, textColor, subColor, cardColor)
            : _buildFamilyDetails(context, ref, family, textColor, subColor, cardColor),
      ),
    );
  }

  Widget _buildNoFamily(BuildContext context, WidgetRef ref, Color textColor, Color subColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom_rounded, size: 80, color: AppColorsPS5.accent.withOpacity(0.5)),
          const SizedBox(height: Spacing.lg),
          Text(
            'Спільні заощадження',
            style: AppTypography.heading2.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Створіть сімейну групу, щоб накопичувати на спільні цілі разом з близькими.',
            style: AppTypography.bodyMedium.copyWith(color: subColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xxl),
          _buildActionButton(
            context,
            'Створити сім\'ю',
            Icons.add_rounded,
            () => ref.read(familyProvider.notifier).createGroup('Моя Сім\'я'),
            true,
          ),
          const SizedBox(height: Spacing.md),
          _buildActionButton(
            context,
            'Приєднатися за кодом',
            Icons.vpn_key_rounded,
            () => _showJoinDialog(context, ref),
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyDetails(BuildContext context, WidgetRef ref, FamilyGroup family, Color textColor, Color subColor, Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.base),
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(color: context.isDark ? AppColorsPS5.border : AppColorsMonitor.border),
          ),
          child: Column(
            children: [
              Text(family.name, style: AppTypography.heading2.copyWith(color: textColor)),
              const SizedBox(height: Spacing.xs),
              Text('Код запрошення: ${family.inviteCode}', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.accent)),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Text('Учасники', style: AppTypography.heading3.copyWith(color: textColor)),
        const SizedBox(height: Spacing.md),
        ...family.members.map((member) => _buildMemberTile(member, textColor, subColor, cardColor)),
        const SizedBox(height: Spacing.lg),
        _buildActionButton(
          context,
          'Додати учасника',
          Icons.person_add_rounded,
          () => ref.read(familyProvider.notifier).addMember('Новий учасник', FamilyRole.member),
          false,
        ),
        const SizedBox(height: Spacing.xxxl),
        TextButton(
          onPressed: () => ref.read(familyProvider.notifier).leaveGroup(),
          child: Text('Покинути групу', style: TextStyle(color: AppColorsPS5.error)),
        ),
      ],
    );
  }

  Widget _buildMemberTile(FamilyMember member, Color textColor, Color subColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColorsPS5.accent.withOpacity(0.2),
            child: Text(member.name[0], style: TextStyle(color: AppColorsPS5.accent)),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTypography.labelMedium.copyWith(color: textColor)),
                Text(member.role.displayNameUA, style: AppTypography.caption.copyWith(color: subColor)),
              ],
            ),
          ),
          Text(
            '${member.totalContributed.toInt()} грн',
            style: AppTypography.monoSmall.copyWith(color: AppColorsPS5.success),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap, bool primary) {
    final accent = context.isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        decoration: BoxDecoration(
          color: primary ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.md),
          border: primary ? null : Border.all(color: accent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary ? Colors.white : accent, size: 20),
            const SizedBox(width: Spacing.sm),
            Text(
              label,
              style: AppTypography.buttonLarge.copyWith(color: primary ? Colors.white : accent),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Приєднатися'),
        content: const TextField(
          decoration: InputDecoration(hintText: 'Введіть код'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
          TextButton(
            onPressed: () {
              ref.read(familyProvider.notifier).joinGroup('NEX-1234');
              Navigator.pop(ctx);
            },
            child: const Text('Приєднатися'),
          ),
        ],
      ),
    );
  }
}
