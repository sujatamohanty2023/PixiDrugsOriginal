import '../Ledger/Payment.dart';
import '../SaleReturn/SaleReturnRequest.dart';
import '../ReturnStock/PurchaseReturnModel.dart';
import '../constant/all.dart';
import '../login/FCMService.dart';
import '../login/RegisterResponse.dart';
import 'ApiUtil/api_exception.dart';

class ApiRepository {
  final Dio dio;

  ApiRepository({Dio? dio}) : dio = dio ?? Dio();

   Future<T> _safeApiCall<T>(Future<Response> Function() request) async {
    if (!await ConnectivityService.isConnected()) {
      throw ApiException('No internet connection');
    }

    try {
      final response = await request();

      print('📡 API CALL: ${response.requestOptions.method} ${response.requestOptions.uri}');
      if (response.requestOptions.data != null) {
        print('📦 Request Data: ${response.requestOptions.data}');
      }
      print('✅ API RESPONSE [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('❌ API ERROR URL: ${response.requestOptions.uri}');
        throw ApiException(
          response.data['message'] ?? 'Unknown server error',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioError catch (dioError) {
      // 👇 Handle 401 token expiration
      if (dioError.response?.statusCode == 401) {
        try {
          print('🔁 Token expired. Refreshing...');
          await _refreshToken();

          // 👇 Retry the original request with updated token
          final retryResponse = await request();
          return retryResponse.data;
        } catch (e) {
          throw ApiException('Authentication failed after token refresh.');
        }
      }

      print('🚨 API ERROR: ${dioError.message}');
      if (dioError.response != null) {
        print('❌ API RESPONSE ERROR: ${dioError.response?.data}');
      }
      throw handleDioError(dioError);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<void> _refreshToken() async {
    try {
      final response = await dio.get(
        '${AppString.baseUrl}api/refresh',
        queryParameters: {
          'token': await SessionManager.getAccessToken(),
          'fcm_token': await FCMService.getFCMToken()
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      final token = response.data['token'];
      await SessionManager.setAccessToken(token);

      print('🔄 Token refreshed successfully');
    } catch (e) {
      print('❌ Failed to refresh token: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> loginUser(String text, String fcmToken) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/login',
      queryParameters: {
        text.contains('@') ? 'email' : 'mobile': text,
        'fcm_token': fcmToken,
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> register(RegisterModel model) {
    return _safeApiCall(() async => dio.post(
      '${AppString.baseUrl}api/store/register',
      data: {
        'name': model.name,
        'email': model.email,
        'phone_number': model.phoneNumber,
        'gander': model.gander,
        'dob': model.dob,
        'password': model.password,
        'address': model.address,
        'country': model.country,
        'state': model.state,
        'city': model.city,
        'pincode': model.pincode,
        'owner_name': model.ownerName,
        'gstin': model.gstin,
        'license':model.license,
      },
      options: Options(headers: {
        'Content-Type': 'application/json',
      }),
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> fetchBanner() {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/getbanners',
      queryParameters: {'access_token': await SessionManager.getAccessToken()},
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> GetUserProfile(String userId) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/userprofile',
      queryParameters: {
        'user_id': userId,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> EditUserProfile(
      String userId,
      String name,
      String ownerName,
      String gender,
      String dob,
      String profilePicture,
      ) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/updateuserprofile',
      queryParameters: {
        'user_id': userId,
        'name': name,
        'owner_name': ownerName,
        'gander': gender,
        'dob': dob,
        'profile_picture': profilePicture,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> UpdateFCM(String userId, String fcmToken) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/updatefcmtoken',
      queryParameters: {
        'user_id': userId,
        'fcm_token': fcmToken,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> barcodeScan(String barcode, String storeId,String seller_id,String customer_id) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/barcodepro',
      queryParameters: {
        'barcode': barcode,
        'store_id': storeId,
        'seller_id': seller_id,
        'customer_id':customer_id,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> customerbarcode(String barcode, String storeId,String customer_id) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/customer-returns/customerbarcode',
      queryParameters: {
        'barcode': barcode,
        'store_id': storeId,
        'customer_id':customer_id,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> PlaceOrderApi(OrderPlaceModel model) {
    return _safeApiCall(() async => dio.post(
      '${AppString.baseUrl}api/checkout',
      data: {
        'seller_id': model.seller_id,
        'name': model.name,
        'phone': model.phone,
        'email': model.email,
        'address': model.address,
        'payment_type': model.payment_type,
        'items': model.toApiFormatProductOrder(),
        if (model.note.isNotEmpty) ...{
          'amount': model.amount,
          'title': model.title,
          'expanse_date': DateTime.now().toString(),
          'note': model.note,
          'store_id': model.seller_id,
        },
        'access_token': await SessionManager.getAccessToken()
      },
      options: Options(headers: {
        'Content-Type': 'application/json',
      }),
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> post_Invoice(Invoice invoice) async {
    final invoiceData = invoice.toJson();
    invoiceData['access_token'] = await SessionManager.getAccessToken();
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/invoicebillupload',
      data: invoiceData,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> edit_Invoice(Invoice invoice) async {
    final invoiceData = invoice.toJson();
    invoiceData['access_token'] = await SessionManager.getAccessToken();
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/updateitem',
      data: invoiceData,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> invoiceDelete(String invoiceId) {
    return _safeApiCall(() async => dio.post(
      '${AppString.baseUrl}api/deleteitem',
      queryParameters: {
        'invoice_id': invoiceId,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> invoiceList(String userId,int page,String query,) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/invoicelist/',
      queryParameters: {
        'user_id': userId,
        'page': page,
        'per_page': 10,
        'search': query,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> stockList(String userId, String apiName,int page,String query,Map<String, String?> filters) async {
    Map<String, dynamic> queryParameters = {
      'user_id': userId,
      'page': page,
      'per_page': 10,  // Adjust the number of results per page as needed
      'search': query,
      'access_token': await SessionManager.getAccessToken(),
    };

    // Add filters dynamically to the query parameters
    filters.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        queryParameters['filters[$key]'] = value;
      }
    });
     return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/$apiName/',
      queryParameters: queryParameters,
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> searchDetail(String query, String storeId,String apiName) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/$apiName/',
      queryParameters: {
        'term': query,
        'store_id':storeId,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> saleList(String userId,int page,String from,String to,String payment_type,String filter) async {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/salelist/',
      queryParameters: {
        'user_id': userId,
        'from_date': from,
        'to_date': to,
        'range': '',
        'filter':filter,
        'payment_type':payment_type,
        'page': page,
        'per_page': 10,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> saleEdit(String billingid, OrderPlaceModel model) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/saleupdate',
      queryParameters: {
        'billingid': billingid,
        'seller_id': model.seller_id,
        'name': model.name,
        'phone': model.phone,
        'email': model.email,
        'address': model.address,
        'items': model.toApiFormatProductOrder(),
        if (model.note.isNotEmpty) ...{
        'amount': model.amount,
        'title': model.title,
        'expanse_date': DateTime.now().toString(),
        'note': model.note,
        'store_id': model.seller_id,
        },
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }

  Future<Map<String, dynamic>> saleDelete(String billingid) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/saleldelete/',
      queryParameters: {
        'billingid': billingid,
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }
  Future<Map<String, dynamic>> leadgerList(String userId,int page,String from,String to,String payment_type,String payment_reason,String filter) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/lesarlisthistory/',
      queryParameters: {
        'user_id': userId,
        'range': '',
        'filter':filter,
        'from_date': from,
        'to_date': to,
        'payment_type':payment_type,
        'payment_reason':payment_reason,
        'page': page,
        'per_page': 10,
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }

  Future<Map<String, dynamic>> payment(Payment payment, String apiName) async {
    final paymentData = payment.toJson();
    paymentData['access_token'] = await SessionManager.getAccessToken();
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/$apiName',
      data: paymentData,
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    ));
  }

  Future<Map<String, dynamic>> paymentDelete(String id) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/deletepayment/',
      queryParameters: {
        'id': id,
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }
  Future<Map<String, dynamic>> invoiceDetail(String invoiceNo, String storeId) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/getinvoicedetails/',
      queryParameters: {
        'invoice_no': invoiceNo,
        'store_id': storeId,
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }

  Future<Map<String, dynamic>> billDetail(String billId, String storeId) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/getsalesetails/',
      queryParameters: {
        'billing_id': billId,
        'store_id': storeId,
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }

  Future<Map<String, dynamic>> fetchList(String storeId, String apiName,int page,{ String from='',String to='',String reason='',String filter=''}) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/$apiName/',
      queryParameters: {
        'store_id': storeId,
        'filter':filter,
        'from_date': from,
        'to_date': to,
        'reason':reason,
        'page': page,
        'per_page': 10,
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }

  Future<Map<String, dynamic>> stockReturn(
      PurchaseReturnModel returnModel, String apiName) async {
    final returnModelData = returnModel.toJson();
    returnModelData['access_token'] = await SessionManager.getAccessToken();
    print('API=${returnModelData.toString()}');
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/stockist-returns/$apiName',
      data: returnModelData,
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    ));
  }

  Future<Map<String, dynamic>> stockReturnDelete(String id) {
    return _safeApiCall(() async => dio.post(
      '${AppString.baseUrl}api/stockist-returns/delete',
      queryParameters: {
        'id': id,
        'access_token': await SessionManager.getAccessToken()
      },
    ));
  }
  Future<Map<String, dynamic>> saleReturn(
      SaleReturnRequest returnModel, String apiName) async {
    final returnModelData = returnModel.toJson();
    returnModelData['access_token'] = await SessionManager.getAccessToken();
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/customer-returns/$apiName',
      data: returnModelData,
      options: Options(headers: {'Content-Type': 'application/json'}),
    ));
  }

  Future<Map<String, dynamic>> Expense({
    required String storeId,
    required String title,
    required String amount,
    required String expanseDate,
    String id = '',
    String note = '',
    required String apiName,
  }) async {
    final params = {
      'store_id': storeId,
      'title': title,
      'amount': amount,
      'expanse_date': expanseDate,
      'note': note,
      if (id.isNotEmpty) 'id': id,
      'access_token': await SessionManager.getAccessToken()
    };

    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/expense/$apiName',
      queryParameters: params,
      options: Options(headers: {'Content-Type': 'application/json'}),
    ));
  }

  Future<Map<String, dynamic>> Staff({
    String id = '',
    String status = '',
    required String name,
    required String email,
    required String phoneNumber,
    required String gender,
    required String dob,
    required String address,
    required String password,
    required String passwordConfirmation,
    required String storeId,
  }) async {
    final params = {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'gander': gender,
      'dob': dob,
      'address': address,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'store_id': storeId,
      if (status.isNotEmpty) 'status': status,
      if (id.isNotEmpty) 'id': id,
      'access_token': await SessionManager.getAccessToken()
    };

    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/staff/store',
      queryParameters: params,
      options: Options(headers: {'Content-Type': 'application/json'}),
    ));
  }
  Future<Map<String, dynamic>> ReportApi({
    required String storeId,required String range
  }) async {
    final params = {
      'store_id': storeId,
      'page': 1,
      'range': range,
      'from_date': '',
      'to_date': '',
      'access_token': await SessionManager.getAccessToken()
    };

    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/dashboardstats',
      queryParameters: params,
      options: Options(headers: {'Content-Type': 'application/json'}),
    ));
  }
}