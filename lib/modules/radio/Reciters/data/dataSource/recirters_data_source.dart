import 'package:dio/dio.dart';
import 'package:islami/core/api/api.dart';
import 'package:islami/modules/radio/Reciters/data/model/Reciters_model.dart';

abstract class RecitersDataSource {
  Future<List<RecitersModel>> getReciters();
}

class RecitersDataSourceImpl implements RecitersDataSource {
  final Dio dio;

  RecitersDataSourceImpl({required this.dio});

  @override
  Future<List<RecitersModel>> getReciters() async {
    final String url = baseUrlOfreciters;

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      final List<dynamic> recitersList = jsonData['reciters'];
      return recitersList.map((item) => RecitersModel.fromJson(item)).toList();
    } else {
      throw Exception();
    }
  }
}
