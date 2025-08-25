import '../Ledger/Payment.dart';
import '../SaleReturn/SaleReturnRequest.dart';
import '../StockReturn/PurchaseReturnModel.dart';
import '../constant/all.dart';
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

      // ✅ Log URL + Method
      print('📡 API CALL: ${response.requestOptions.method} ${response.requestOptions.uri}');
      // ✅ Log request data (if present)
      if (response.requestOptions.data != null) {
        print('📦 Request Data: ${response.requestOptions.data}');
      }
      // ✅ Log response
      print('✅ API RESPONSE [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
          response.data['message'] ?? 'Unknown server error',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    }on DioError catch (dioError) {
      // ❌ Log DioError details
      print('🚨 API ERROR: ${dioError.message}');
      if (dioError.response != null) {
        print('❌ API RESPONSE ERROR: ${dioError.response?.data}');
      }
      throw handleDioError(dioError);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
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
  Future<Map<String, dynamic>> fetchBanner() {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/getbanners',
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> GetUserProfile(String userId) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/userprofile',
      queryParameters: {'user_id': userId},
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> EditUserProfile(
      String userId,
      String name,
      String email,
      String phoneNumber,
      String gender,
      String dob,
      String profilePicture,
      ) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/updateuserprofile',
      queryParameters: {
        'user_id': userId,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'gander': gender,
        'dob': dob,
        'profile_picture': profilePicture,
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> UpdateFCM(String userId, String fcmToken) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/updatefcmtoken',
      queryParameters: {
        'user_id': userId,
        'fcm_token': fcmToken,
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> barcodeScan(String barcode, String storeId,String seller_id,String customer_id) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/barcodepro',
      queryParameters: {
        'barcode': barcode,
        'store_id': storeId,
        'seller_id': seller_id,
        'customer_id':customer_id
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> PlaceOrderApi(OrderPlaceModel model) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/checkout',
      queryParameters: {
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
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> post_Invoice(Invoice invoice) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/invoicebillupload',
      data: invoice.toJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> edit_Invoice(Invoice invoice) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/updateitem',
      data: invoice.toJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> invoiceDelete(String invoiceId) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/deleteitem',
      queryParameters: {'invoice_id': invoiceId},
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> invoiceList(String userId) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/invoicelist/',
      queryParameters: {
        'user_id': userId,
        'page': 1,
        'per_page': 20,
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<List<dynamic>> stockList(String userId, String apiName) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/$apiName/',
      queryParameters: {'user_id': userId},
    )).then((data) => List<dynamic>.from(data));
  }
  Future<Map<String, dynamic>> searchDetail(String query, String storeId,String apiName) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/$apiName/',
      queryParameters: {'term': query,'store_id':storeId},
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> saleList(String userId) async {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/salelist/',
      queryParameters: {
        'user_id': userId,
        'from_date': '',
        'to_date': '',
        'range': '',
      },
    )).then((data) => Map<String, dynamic>.from(data));
  }
  Future<Map<String, dynamic>> saleEdit(String billingid, OrderPlaceModel model) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/saleupdate',
      queryParameters: {
        'billingid': billingid,
        'seller_id': model.seller_id,
        'name': model.name,
        'phone': model.phone,
        'email': model.email,
        'address': model.address,
        'items': model.toApiFormatProductOrder(),
      },
    ));
  }

  Future<Map<String, dynamic>> saleDelete(String billingid) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/saleldelete/',
      queryParameters: {'billingid': billingid},
    ));
  }
  Future<Map<String, dynamic>> leadgerList(String userId) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/lesarlisthistory/',
      queryParameters: {'user_id': userId},
    ));
  }

  Future<Map<String, dynamic>> payment(Payment payment, String apiName) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/$apiName',
      data: payment.toJson(),
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    ));
  }

  Future<Map<String, dynamic>> paymentDelete(String id) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/deletepayment/',
      queryParameters: {'id': id},
    ));
  }
  Future<Map<String, dynamic>> invoiceDetail(String invoiceNo, String storeId) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/getinvoicedetails/',
      queryParameters: {
        'invoice_no': invoiceNo,
        'store_id': storeId,
      },
    ));
  }

  Future<Map<String, dynamic>> billDetail(String billId, String storeId) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/getsalesetails/',
      queryParameters: {
        'billing_id': billId,
        'store_id': storeId,
      },
    ));
  }

  Future<Map<String, dynamic>> fetchList(String storeId, String apiName) {
    return _safeApiCall(() => dio.get(
      '${AppString.baseUrl}api/$apiName/',
      queryParameters: {
        'store_id': storeId,
        'page': 1,
      },
    ));
  }

  Future<Map<String, dynamic>> stockReturn(
      PurchaseReturnModel returnModel, String apiName) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/stockist-returns/$apiName',
      data: returnModel.toJson(),
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    ));
  }

  Future<Map<String, dynamic>> stockReturnDelete(String id) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/stockist-returns/delete',
      queryParameters: {'id': id},
    ));
  }
  Future<Map<String, dynamic>> saleReturn(
      SaleReturnRequest returnModel, String apiName) {
    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/customer-returns/$apiName',
      data: returnModel.toJson(),
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
  }) {
    final params = {
      'store_id': storeId,
      'title': title,
      'amount': amount,
      'expanse_date': expanseDate,
      'note': note,
      if (id.isNotEmpty) 'id': id,
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
  }) {
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
    };

    return _safeApiCall(() => dio.post(
      '${AppString.baseUrl}api/staff/store',
      queryParameters: params,
      options: Options(headers: {'Content-Type': 'application/json'}),
    ));
  }

}

