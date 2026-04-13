/// Модель освітнього уроку.
class AcademyLesson {
  final String id;
  final String title;
  final String description;
  final String content;
  final int xpReward;
  final bool isCompleted;
  final LessonCategory category;

  AcademyLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.xpReward,
    this.isCompleted = false,
    required this.category,
  });
}

enum LessonCategory {
  basics,
  savings,
  investing,
  family,
}

extension LessonCategoryExt on LessonCategory {
  String get displayNameUA {
    switch (this) {
      case LessonCategory.basics: return 'Основи';
      case LessonCategory.savings: return 'Заощадження';
      case LessonCategory.investing: return 'Інвестиції';
      case LessonCategory.family: return 'Сімейний бюджет';
    }
  }
}
