import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

// const baseURL = 'http://localhost:3000'; // Replace with your API base URL
const baseURL = 'https://chatapi.vienvu.com'; // Replace with your API base URL
const socketURL = 'https://socket.vienvu.com'; // Replace with your API base URL

class API extends getx.GetxService {
  // Define your API methods here

  static API get to => getx.Get.put(API());
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

  uploadFile(
    XFile file, {
    Map<String, dynamic>? data,
  }) async {
    final token = GetStorage().read('token');
    if (kIsWeb) {
      // Handle web file upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name.split('/').last,
        ),
        ...?data,
      });
      final response = await dio.post(
        baseURL + '/files/store',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    }
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.name.split('/').last,
      ),
    });
    final response = await dio.post(
      baseURL + '/files/store',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return response.data;
  }
}
