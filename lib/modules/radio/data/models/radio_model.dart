import 'package:islami/modules/radio/domain/entities/entitie.dart';

class RadioModel extends RadioEntity {
  RadioModel({required super.id, required super.name, required super.url});
   factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}