import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;

  static init() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://opentdb.com/',
      receiveDataWhenStatusError: true,
    ));
  }

  static Future<Response> getQuestions({
    String path = 'api.php',
    required Map<String, dynamic> queryParams,
  }) async {
    return await dio.get(path, queryParameters: queryParams);
  }
}
