import 'package:dio/dio.dart';
import 'package:islami/core/api/api.dart';
import 'package:islami/modules/hadith/data/hadith_model.dart';

abstract class HadithRemoteDataSource {
  Future<List<HadithModel>> getHadiths({required int page, int? id});
}

class HadithRemoteDataSourceImpl implements HadithRemoteDataSource {
  final Dio dio;

  HadithRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HadithModel>> getHadiths({required int page, int? id}) async {
    const ApiKey = "$apiKey";
    final String url = "$baseUrlOfHadith";

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {'X-API-Key': apiKey, 'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final List<dynamic> hadithsList = jsonData['hadiths']['data'];

        return hadithsList
            .where((item) => item.isNotEmpty)
            .map((item) => HadithModel.fromJson(item))
            .toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }
}
