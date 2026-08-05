import 'package:dio/dio.dart';
import 'package:islami/core/api/api.dart';
import 'package:islami/modules/radio/Radio/data/models/radio_model.dart';

abstract class RadioDataSource {
  Future<List<RadioModel>> getRadio();
}

class RadioDataSourceImpl implements RadioDataSource {
  final Dio dio;

  RadioDataSourceImpl({required this.dio});

  @override
  Future<List<RadioModel>> getRadio() async {
    final String url = "$baseUrlOfRadio";

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {'X-API-Key': apiKey, 'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final List<dynamic> radioList = jsonData['radios'];
        return radioList.map((item) => RadioModel.fromJson(item)).toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }
}
