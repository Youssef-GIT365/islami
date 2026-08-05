import 'package:islami/modules/radio/Radio/domain/entities/entitie.dart';

class RadioModel extends RadioEntity {
  RadioModel({
    required super.id,
    required super.name,
    required super.url,
    required super.enName,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    final String rawUrl = (json['url'] ?? '').toString();
    final String rawName = (json['name'] ?? '').toString();

    return RadioModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: rawName,
      url: rawUrl,
      enName: _extractEnglishName(rawUrl, rawName),
    );
  }

  static String _extractEnglishName(String rawUrl, String defaultName) {
    if (rawUrl.trim().isEmpty) return defaultName;
    try {
      final String slug = rawUrl.split('/').last;
      if (slug.isEmpty) return defaultName;

      final List<String> words = slug.replaceAll('_', ' ').split(' ');
      final List<String> capitalizedWords = [];

      for (final word in words) {
        if (word.isNotEmpty) {
          capitalizedWords.add('${word[0].toUpperCase()}${word.substring(1)}');
        }
      }

      final String result = capitalizedWords.join(' ');
      return result.isEmpty ? defaultName : result;
    } catch (_) {
      return defaultName;
    }
  }
}
