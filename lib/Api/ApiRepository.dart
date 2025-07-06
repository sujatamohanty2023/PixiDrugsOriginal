// api_repository.dart
import 'package:pixidrugs/constant/all.dart';

class ApiRepository {
  final Dio dio;

  ApiRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<Map<String, dynamic>> loginUser(
      String mobile, String fcm_token,String role) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/login',
        queryParameters: {'mobile': mobile, 'fcm_token': fcm_token,'role':role},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }
  Future<Map<String, dynamic>> fetchBanner() async {
    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/getbanners',
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception("Failed to load data: $e");
    }
  }
  Future<Map<String, dynamic>> GetUserProfile(String user_id) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/userprofile',
        queryParameters: {'user_id': user_id},
      );
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<Map<String, dynamic>> EditUserProfile(
      String user_id,
      String name,
      String email,
      String phone_number,
      String gander,
      String dob,
      String profile_picture) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/updateuserprofile',
        queryParameters: {
          'user_id': user_id,
          'name': name,
          'email': email,
          'phone_number': phone_number,
          'gander': gander,
          'dob': dob,
          'profile_picture': profile_picture
        },
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }
  Future<Map<String, dynamic>> UpdateFCM(
      String user_id, String fcm_token) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/updatefcmtoken',
        queryParameters: {'user_id': user_id, 'fcm_token': fcm_token},
      );
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to Edit Record');
      }
    } catch (e) {
      throw Exception('Failed to Edit Record: $e');
    }
  }

  Future<Map<String, dynamic>> barcodeScan(String barcode) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/barcodepro',
        queryParameters: {'barcode': barcode},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to barcodeScan');
      }
    } catch (e) {
      throw Exception('Failed to barcodeScan: $e');
    }
  }
  Future<Map<String, dynamic>> post_Invoice(Invoice invoice) async {
    // Check internet connection
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Perform POST request
      final response = await dio.post(
        '${AppString.baseUrl}api/invoicebillupload',
        data: invoice.toJson(), // Sending JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Ensures raw JSON POST
          },
        ),
      );

      // Debug print
      print('API Response: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('POST error: $e');
      throw Exception('Failed to post invoice: $e');
    }
  }
  Future<Map<String, dynamic>> edit_Invoice(Invoice invoice) async {
    // Check internet connection
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Perform POST request
      final response = await dio.post(
        '${AppString.baseUrl}api/updateitem',
        data: invoice.toJson(), // Sending JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Ensures raw JSON POST
          },
        ),
      );

      // Debug print
      print('API Response: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('POST error: $e');
      throw Exception('Failed to post invoice: $e');
    }
  }

  Future<Map<String, dynamic>> invoiceList(String userId) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/invoicelist/',
        queryParameters: {'user_id': '117','page':1,'per_page':20},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
  Future<Map<String, dynamic>> stockList(String userId,String apiName) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/$apiName/',
        //queryParameters: {'user_id': userId},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}
