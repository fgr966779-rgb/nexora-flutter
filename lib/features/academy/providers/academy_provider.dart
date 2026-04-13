import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/academy_model.dart';

final academyProvider = StateNotifierProvider<AcademyNotifier, List<AcademyLesson>>((ref) {
  return AcademyNotifier();
});

class AcademyNotifier extends StateNotifier<List<AcademyLesson>> {
  AcademyNotifier() : super(_defaultLessons());

  static List<AcademyLesson> _defaultLessons() {
    return [
      AcademyLesson(
        id: '1',
        title: 'Правило 50/30/20',
        description: 'Як правильно розподіляти дохід.',
        content: 'Розподіляйте 50% на потреби, 30% на бажання та 20% на заощадження...',
        xpReward: 50,
        category: LessonCategory.basics,
      ),
      AcademyLesson(
        id: '2',
        title: 'Фінансова подушка',
        description: 'Навіщо вона потрібна та як створити.',
        content: 'Фінансова подушка має покривати 3-6 місяців ваших витрат...',
        xpReward: 100,
        category: LessonCategory.savings,
      ),
      AcademyLesson(
        id: '3',
        title: 'Складні відсотки',
        description: 'Магія довгострокових заощаджень.',
        content: 'Складні відсотки — це коли ваші відсотки теж приносять відсотки...',
        xpReward: 150,
        category: LessonCategory.investing,
      ),
    ];
  }

  void completeLesson(String id) {
    state = [
      for (final lesson in state)
        if (lesson.id == id)
          AcademyLesson(
            id: lesson.id,
            title: lesson.title,
            description: lesson.description,
            content: lesson.content,
            xpReward: lesson.xpReward,
            category: lesson.category,
            isCompleted: true,
          )
        else
          lesson,
    ];
  }
}
