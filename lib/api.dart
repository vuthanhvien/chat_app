import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// const baseURL = 'http://localhost:3000'; // Replace with your API base URL
const baseURL = 'https://chatapi.vienvu.com'; // Replace with your API base URL
const socketURL = 'https://socket.vienvu.com'; // Replace with your API base URL

class API extends GetxService {
  // Define your API methods here

  static API get to => Get.put(API());
  Dio dio = Dio();
  Future fetchData(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = GetStorage().read('token');
    final response = await dio.get(
      baseURL + path,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return response.data;
  }

  Future postData(String path, Map<String, dynamic> data) async {
    final token = GetStorage().read('token');
    final response = await dio.post(
      baseURL + path,
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return response.data;
  }
}
