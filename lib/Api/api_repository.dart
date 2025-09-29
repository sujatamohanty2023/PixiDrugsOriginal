import '../Ledger/Payment.dart';
import '../SaleReturn/SaleReturnRequest.dart';
import '../ReturnStock/PurchaseReturnModel.dart';
import '../../constant/all.dart';
import '../constant/utils.dart';
import '../login/FCMService.dart';
import '../login/RegisterResponse.dart';
import 'ApiUtil/api_exception.dart';

class ApiRepository {
  final Dio dio;

  ApiRepository({Dio? dio}) : dio = dio ?? Dio();

  /// Sanitize response data to handle inconsistent data types from API
  T _sanitizeResponseData<T>(dynamic data) {
    if (data == null) return {} as T;
    
    // If it's already the expected type, return as-is
    if (data is T) return data;
    
    // For Map responses, ensure all values are safely accessible
    if (data is Map && T == Map<String, dynamic>) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        sanitized[key.toString()] = value;
      });
      return sanitized as T;
    }
    
    // For List responses, ensure each item is properly formatted
    if (data is List && T == List<dynamic>) {
      return data.map((item) => item).toList() as T;
    }
    
    // Default: return the data as-is with type casting
    return data as T;
  }

  Future<T> _safeApiCall<T>(Future<Response> Function() request) async {
    if (!await ConnectivityService.isConnected()) {
      throw ApiException('No internet connection',errorType:ApiErrorType.network);
    }
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _sanitizeResponseData<T>(response.data);
        if (response.statusCode == 201 && AppUtils.checkForInactiveAccount(data)) {
          throw ApiException( response.data['error'], isInactiveAccount: true,errorType:ApiErrorType.authentication);
        }
        return data;
      } else {
        final message = response.data['message'] ?? 'Server error';
        throw ApiException(message, statusCode: response.statusCode);
      }
    } on DioError catch (dioError) {
      if (dioError.response?.statusCode == 401) {
        try {
          await _refreshToken();
          final retryResponse = await request();
          return _sanitizeResponseData<T>(retryResponse.data);
        } catch (_) {
          throw ApiException('Authentication failed. Please login again.');
        }
      }
      throw handleDioError(dioError);
    } catch (e) {
      throw ApiException('$e');
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
  Future<Map<String, dynamic>> PlaceOrderApi(OrderPlaceModel model) async {
     var user_id=await SessionManager.getUserId();
    return _safeApiCall(() async => dio.post(
      '${AppString.baseUrl}api/checkout',
      data: {
        'sold_by':user_id,
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
  Future<Map<String, dynamic>> invoiceDelete(String id,String storeId) {
    return _safeApiCall(() async => dio.post(
      '${AppString.baseUrl}api/deleteitem',
      queryParameters: {
        'id': id,
        'store_id':storeId,
        'access_token': await SessionManager.getAccessToken()
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> invoiceList(String userId,int page,String from,String to,String payment_type,String query,) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/invoicelist/',
      queryParameters: {
        'user_id': userId,
        'page': page,
        'from_date': from,
        'to_date': to,
        'range': '',
        'payment_type':payment_type,
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

    filters.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        queryParameters['filters[$key]'] = value;
      }
    });
    final uri = Uri.parse(AppString.baseUrl).replace(
      path: 'api/$apiName/',
      queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())),
    );

    print('🔎 API URL with filters: $uri');

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

  Future<Map<String, dynamic>> saleDelete(String billingid,String storeId) {
    return _safeApiCall(() async => dio.get(
      '${AppString.baseUrl}api/saleldelete/',
      queryParameters: {
        'billingid': billingid,
        'String storeId':storeId,
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