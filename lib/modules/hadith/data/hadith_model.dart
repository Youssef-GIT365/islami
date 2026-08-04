import 'package:islami/modules/hadith/domain/entities/hadith_entity.dart';

class HadithModel extends HadithEntity {
  HadithModel({required super.hadithArabic, required super.id});

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] ?? 0,
      hadithArabic: json['hadithArabic'] ?? '',
    );
  }
}
