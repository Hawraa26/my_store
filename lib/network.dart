

import 'package:dio/dio.dart';

class Network {
  final Dio dio = Dio();

  Future<Response> get(String url) async {
    return await dio.get(url);
  }
  Future<Response> post(
      String url, {
        dynamic data,
      }) async {
    return await dio.post(
      url,
      data: data,
    );
  }
  Future<Response> put(
      String url, {
        dynamic data,
      }) async {
    return await dio.put(
      url,
      data: data,
    );
  }
  Future<Response> delete(String url) async {
    return await dio.delete(url);
  }
}
