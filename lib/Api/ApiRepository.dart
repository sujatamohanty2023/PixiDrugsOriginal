// api_repository.dart
import 'package:PixiDrugs/Ledger/Payment.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../SaleReturn/SaleReturnRequest.dart';
import '../StockReturn/PurchaseReturnModel.dart';

class ApiRepository {
  final Dio dio;

  ApiRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<Map<String, dynamic>> loginUser(
      String text, String fcm_token) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/login',
        queryParameters: {text.contains('@')?'email': 'mobile': text, 'fcm_token': fcm_token},
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

  Future<Map<String, dynamic>> barcodeScan(String barcode,String store_id) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/barcodepro',
        queryParameters: {'barcode': barcode,'store_id': store_id},
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
  Future<Map<String, dynamic>> PlaceOrderApi(OrderPlaceModel model) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }
    try {
      final response = await dio.post(
        '${AppString.baseUrl}api/checkout',
        queryParameters: {
          'seller_id': model.seller_id,
          'name': model.name,
          'phone': model.phone,
          'email': model.email,
          'address':model.address,
          'items': model.toApiFormatProductOrder()
        },
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: ${response}');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to checkout');
      }
    } catch (e) {
      throw Exception('Failed to checkout: $e');
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
  Future<Map<String, dynamic>> invoiceDelete(String invoice_id) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.post(
        '${AppString.baseUrl}api/deleteitem',
        queryParameters: {'invoice_id': invoice_id},
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

  Future<Map<String, dynamic>> invoiceList(String userId) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/invoicelist/',
        queryParameters: {'user_id': userId,'page':1,'per_page':20},
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
  Future<List<dynamic>> stockList(String userId,String apiName) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/$apiName/',
        queryParameters: {'user_id': userId},
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
  Future<Map<String, dynamic>> saleList(String userId) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/salelist/',
        queryParameters: {'user_id': userId,
                          'from_date':'',
                          'to_date':'',
                          'range':''
        },
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch Sale List');
      }
    } catch (e) {
      throw Exception('Failed to Sale list: $e');
    }
  }
  Future<Map<String, dynamic>> saleEdit(String billingid,OrderPlaceModel model) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }
    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/saleupdate',
        queryParameters: {
          'billingid':billingid,
          'seller_id': model.seller_id,
          'name': model.name,
          'phone': model.phone,
          'email': model.email,
          'address':model.address,
          'items': model.toApiFormatProductOrder()
        },
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: ${response}');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to checkout');
      }
    } catch (e) {
      throw Exception('Failed to checkout: $e');
    }
  }
  Future<Map<String, dynamic>> saleDelete(String billingid) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/saleldelete/',
        queryParameters: {'billingid': billingid},
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
  Future<Map<String, dynamic>> leadgerList(String userId) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/lesarlisthistory/',
        queryParameters: {'user_id': userId},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch Ledger List');
      }
    } catch (e) {
      throw Exception('Failed to Ledger list: $e');
    }
  }
  Future<Map<String, dynamic>> payment(Payment payment,String apiName) async {
    // Check internet connection
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Perform POST request
      final response = await dio.post(
        '${AppString.baseUrl}api/$apiName',
        data: payment.toJson(), // Sending JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Ensures raw JSON POST
          },
        ),
      );

      // Debug print
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API Response: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('POST error: $e');
      throw Exception('Failed to post invoice: $e');
    }
  }
  Future<Map<String, dynamic>> paymentDelete(String id) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/deletepayment/',
        queryParameters: {'id': id},
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

  Future<Map<String, dynamic>> invoiceDetail(String invoice_no,String store_id) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/getinvoicedetails/',
        queryParameters: {'invoice_no': invoice_no,'store_id': store_id},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load invoice');
      }
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }

  Future<Map<String, dynamic>> billDetail(String bill_id,String store_id) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/getsalesetails/',
        queryParameters: {'billing_id': bill_id,'store_id': store_id},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load invoice');
      }
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }
  Future<Map<String, dynamic>> fetchList(String store_id,String apiName) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/$apiName/',
        queryParameters: {'store_id': store_id,'page':1},
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
  Future<Map<String, dynamic>> stockReturn(PurchaseReturnModel returnModel,String apiName) async {
    // Check internet connection
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Perform POST request
      final response = await dio.post(
        '${AppString.baseUrl}api/stockist-returns/$apiName',
        data: returnModel.toJson(), // Sending JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Ensures raw JSON POST
          },
        ),
      );

      // Debug print
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API Response: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('POST error: $e');
      throw Exception('Failed to post invoice: $e');
    }
  }
  Future<Map<String, dynamic>> stockReturnDelete(String id) async {
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      final response = await dio.post(
        '${AppString.baseUrl}api/stockist-returns/delete',
        queryParameters: {'id': id},
      );
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API URL: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete ');
      }
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }
  Future<Map<String, dynamic>> saleReturn(SaleReturnRequest returnModel,String apiName) async {
    // Check internet connection
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Perform POST request
      final response = await dio.post(
        '${AppString.baseUrl}api/customer-returns/$apiName',
        data: returnModel.toJson(), // Sending JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Ensures raw JSON POST
          },
        ),
      );

      // Debug print
      print('API URL➡️ Request URL: ${response.requestOptions.uri}');
      print('API Response: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('POST error: $e');
      throw Exception('Failed to post invoice: $e');
    }
  }
  Future<Map<String, dynamic>> Expense(
      String id,
      String storeId,
      String title,
      String amount,
      String expanseDate,
      String note,
      String apiName,
      ) async {
    // Check internet connection
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'store_id': storeId,
        'title': title,
        'amount': amount,
        'expanse_date': expanseDate,
        'note': note,
      };

      if (id.isNotEmpty) {
        queryParams['id'] = id;
      }

      // Perform POST request
      final response = await dio.post(
        '${AppString.baseUrl}api/expense/$apiName',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Debug output
      print('API URL ➡️ ${response.requestOptions.uri}');
      print('API Response: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('POST error: $e');
      throw Exception('Failed to post expense: $e');
    }
  }
  Future<Map<String, dynamic>> Staff(
       String id,
      String name,
       String email,
       String phone_number,
       String gender,
       String dob,
       String address,
       String password,
       String password_confirmation,
       String store_id,
      String status,
      ) async {
    // Check internet connection
    bool isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'name': name,
        'email': email,
        'phone_number': phone_number,
        'gender': gender,
        'dob': dob,
        'address': address,
        'password': password,
        'password_confirmation': password_confirmation,
        'store_id': store_id,
      };

      if (status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (id.isNotEmpty) {
        queryParams['id'] = id;
      }

      // Perform POST request
      final response = await dio.post(
        '${AppString.baseUrl}api/staff/store',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Debug output
      print('API URL ➡️ ${response.requestOptions.uri}');
      print('API Response: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('POST error: $e');
      throw Exception('Failed to post expense: $e');
    }
  }

}
