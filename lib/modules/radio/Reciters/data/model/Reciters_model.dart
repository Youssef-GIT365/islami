import 'package:islami/modules/radio/Reciters/domain/entities/reciters_entitie.dart';

class RecitersModel extends RecitersEntitie {
  RecitersModel({
    required super.name,
    required super.url,
    required super.id,
    required super.enName,
  });

  factory RecitersModel.fromJson(Map<String, dynamic> json) {
    final String rawName = (json['name'] ?? '').toString();

    String rawUrl = '';
    if (json['moshaf'] is List && (json['moshaf'] as List).isNotEmpty) {
      final List moshafs = json['moshaf'];

      final primaryMoshaf = moshafs.firstWhere(
        (m) => m is Map && (m['name']?.toString().contains('مرتل') ?? false),
        orElse: () => moshafs.first,
      );

      if (primaryMoshaf is Map && primaryMoshaf.containsKey('server')) {
        rawUrl = (primaryMoshaf['server'] ?? '').toString();
      }
    }

    return RecitersModel(
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
      final Uri uri = Uri.parse(rawUrl.trim());
      final List<String> pathSegments = uri.pathSegments
          .where((s) => s.isNotEmpty)
          .toList();

      if (pathSegments.isEmpty) return defaultName;

      final String slug = pathSegments.first;

      final List<String> words = slug
          .replaceAll('_', ' ')
          .replaceAll('-', ' ')
          .split(' ');
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
