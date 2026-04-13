import 'package:flutter/material.dart';

/// Стадія росту рослини в саду.
enum PlantGrowthStage {
  seed,
  sprout,
  growing,
  mature,
  flowering;

  /// Емодзі для кожної стадії росту.
  String get emoji {
    switch (this) {
      case PlantGrowthStage.seed: return '🌱'; // Насіння/паросток
      case PlantGrowthStage.sprout: return '🌿';
      case PlantGrowthStage.growing: return '🪴';
      case PlantGrowthStage.mature: return '🌳';
      case PlantGrowthStage.flowering: return '🌸';
    }
  }

  /// Назва стадії українською.
  String get displayNameUA {
    switch (this) {
      case PlantGrowthStage.seed: return 'Насіння';
      case PlantGrowthStage.sprout: return 'Паросток';
      case PlantGrowthStage.growing: return 'Росте';
      case PlantGrowthStage.mature: return 'Доросла';
      case PlantGrowthStage.flowering: return 'Квітне';
    }
  }
}

/// Модель рослини в саду.
class GardenPlant {
  final String id;
  final String name;
  final PlantGrowthStage stage;
  final DateTime plantedAt;
  final double health; // 0.0 to 1.0

  GardenPlant({
    required this.id,
    required this.name,
    this.stage = PlantGrowthStage.seed,
    required this.plantedAt,
    this.health = 1.0,
  });

  factory GardenPlant.fromJson(Map<String, dynamic> json) {
    return GardenPlant(
      id: json['id'] as String,
      name: json['name'] as String,
      stage: PlantGrowthStage.values.firstWhere((e) => e.name == json['stage']),
      plantedAt: DateTime.parse(json['plantedAt'] as String),
      health: (json['health'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stage': stage.name,
      'plantedAt': plantedAt.toIso8601String(),
      'health': health,
    };
  }

  GardenPlant copyWith({
    String? id,
    String? name,
    PlantGrowthStage? stage,
    DateTime? plantedAt,
    double? health,
  }) {
    return GardenPlant(
      id: id ?? this.id,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      plantedAt: plantedAt ?? this.plantedAt,
      health: health ?? this.health,
    );
  }
}

/// Стан віртуального саду.
class GardenState {
  final List<GardenPlant> plants;
  final int level;

  GardenState({
    this.plants = const [],
    this.level = 1,
  });

  factory GardenState.fromJson(Map<String, dynamic> json) {
    return GardenState(
      plants: (json['plants'] as List<dynamic>)
          .map((e) => GardenPlant.fromJson(e as Map<String, dynamic>))
          .toList(),
      level: json['level'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plants': plants.map((e) => e.toJson()).toList(),
      'level': level,
    };
  }
}
