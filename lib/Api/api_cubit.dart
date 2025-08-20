// api_cubit.dart

import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/Ledger/Payment.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/SaleReturn/BillingModel.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/search/customerModel.dart';
import 'package:PixiDrugs/search/sellerModel.dart';

import '../Expense/ExpenseResponse.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../SaleReturn/SaleReturnRequest.dart';
import '../Staff/StaffModel.dart';
import '../StockReturn/PurchaseReturnModel.dart';
import 'api_repository.dart';

class ApiCubit extends Cubit<ApiState> {
  final ApiRepository apiRepository;

  ApiCubit(this.apiRepository) : super(ApiInitial());

//------------------------------------------------------------------------------------
  Future<void> login(
      {required String text, required String fcm_token}) async {
    try {
      emit(LoginLoading());
      final response = await apiRepository.loginUser(text, fcm_token);

      final loginModel = LoginResponse.fromJson(response);
      emit(LoginLoaded(loginResponse: loginModel));
    } catch (e) {
      emit(LoginError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchBanner() async {
    try {
      emit(BannerLoading());
      final response = await apiRepository.fetchBanner();
      final banner = response['banners']['data'] as List;

      final bannerModel =
          banner.map((json) => BannerModel.fromJson(json)).toList();
      emit(BannerLoaded(banner: bannerModel));
    } catch (e) {
      emit(BannerError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  UserProfileResponse? _cachedUserModel;

  UserProfileResponse? get cachedUser => _cachedUserModel;

  Future<void> GetUserData({required String userId, bool useCache = true}) async {
    if (useCache && _cachedUserModel != null) {
      emit(UserProfileLoaded(userModel: _cachedUserModel!));
      return;
    }

    emit(UserProfileLoading());

    try {
      final response = await apiRepository.GetUserProfile(userId);
      final model = UserProfileResponse.fromJson(response);

      _cachedUserModel = model;
      emit(UserProfileLoaded(userModel: model));
    } catch (e) {
      emit(UserProfileError('Error: $e'));
    }
  }

  //------------------------------------------------------------------------------------
  Future<void> updateUserData(
      {required String user_id,
      required String name,
      required String email,
      required String phone_number,
      required String gander,
      required String dob,
      required String profile_picture}) async {
    try {
      emit(EditProfileLoading());
      final response = await apiRepository.EditUserProfile(
          user_id, name, email, phone_number, gander, dob, profile_picture);
      final data = response['user'];
      final message = response['message'];
      final model = UserProfile.fromJson(data);
      emit(EditProfileLoaded(userModel: model, message: message));
    } catch (e) {
      emit(EditProfileError('Error: $e'));
    }
  }

  //------------------------------------------------------------------------------------
  Future<void> updateFCMtoken({
    required String user_id,
    required String fcm_token,
  }) async {
    try {
      emit(UpdateFCMTokenLoading());
      final response = await apiRepository.UpdateFCM(user_id, fcm_token);
      final data = response['message'];

      emit(UpdateFCMTokenLoaded(message: data));
    } catch (e) {
      emit(UpdateFCMTokenError('Error: $e'));
    }
  }

  //------------------------------------------------------------------------------------
  Future<void> BarcodeScan({required String code,required String storeId,String source = 'scan'}) async {
    try {
      emit(BarcodeScanLoading());
      final response = await apiRepository.barcodeScan(code,storeId);
      if (response['status'] == 'not_found') {
        emit(BarcodeScanError(response['message'] ?? 'No product found.'));
        return;
      }
      final data = response['data'] as List;
      final list = data.map((json) => InvoiceItem.fromJson(json)).toList();
      emit(BarcodeScanLoaded(list: list,source: source));
    } catch (e) {
      emit(BarcodeScanError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> SearchSellerDetail({required String query}) async {
      try {
        emit(SearchSellerLoading());
        final response = await apiRepository.searchDetail(query,'searchseller');
        final data = response['data'] as List;
        final list = data.map((json) => Seller.fromJson(json)).toList();
        emit(SearchSellerLoaded(sellerList: list));
      } catch (e) {
        emit(SearchSellerError('Error: $e'));
      }
  }
  //------------------------------------------------------------------------------------
  Future<void> SearchCustomerDetail({required String query}) async {
    try {
      emit(SearchUserLoading());
      final response = await apiRepository.searchDetail(query,'searchuser');
      final data = response['data'] as List;
      final list = data.map((json) => CustomerModel.fromJson(json)).toList();
      emit(SearchUserLoaded(customerList: list));
    } catch (e) {
      emit(SearchUserError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> placeOrder({required OrderPlaceModel orderPlaceModel}) async {
    try {
      emit(OrderPlaceLoading());
      final response = await apiRepository.PlaceOrderApi(orderPlaceModel);
      final message = response['message'];
      final saleModel = SaleModel.fromBillingResponse(response);

      emit(OrderPlaceLoaded(message: message,saleModel: saleModel));
    } catch (e) {
      emit(OrderPlaceError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> InvoiceAdd({required Invoice invoice}) async {
    try {
      emit(InvoiceAddLoading());
      final response = await apiRepository.post_Invoice(invoice);
      final message = response['message'];
      final status = response['status'];
      if(status=='success') {
        emit(InvoiceAddLoaded(message: message, status: status));
      }else{
        emit(InvoiceAddError('Error: $message'));
      }
    } catch (e) {
      emit(InvoiceAddError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> InvoiceEdit({required Invoice invoice}) async {
    try {
      emit(InvoiceEditLoading());
      final response = await apiRepository.edit_Invoice(invoice);
      final message = response['message'];
      final status = response['status'];
      if(status=='success') {
        emit(InvoiceEditLoaded(message: message, status: status));
      }else{
        emit(InvoiceEditError('Error: $message'));
      }
    } catch (e) {
      emit(InvoiceEditError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> InvoiceDelete({required String invoice_id}) async {
    try {
      emit(InvoiceDeleteLoading());
      final response = await apiRepository.invoiceDelete(invoice_id);
      final message = response['message'];
      emit(InvoiceDeleteLoaded(message: message));
    } catch (e) {
      emit(InvoiceDeleteError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchInvoiceList({required String user_id}) async {
    try {
      emit(InvoiceListLoading());
      final response = await apiRepository.invoiceList(user_id);
      final data = response['data'] as List;
      final list = data.map((json) => Invoice.fromJson(json)).toList();
      emit(InvoiceListLoaded(invoiceList: list));
    } catch (e) {
      emit(InvoiceListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchStockList({required String user_id}) async {
    try {
      emit(StockListLoading());
      final response = await apiRepository.stockList(user_id,'stocklist');
      final list = response.map((json) => InvoiceItem.fromJson(json)).toList();
      emit(StockListLoaded(stockList: list));
    } catch (e) {
      emit(StockListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> expiredStockList({required String user_id}) async {
    try {
      emit(ExpiredStockListLoading());
      final response = await apiRepository.stockList(user_id,'expired');
      final list = response.map((json) => InvoiceItem.fromJson(json)).toList();
      emit(ExpiredStockListLoaded(stockList: list));
    } catch (e) {
      emit(ExpiredStockListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> expireSoonStockList({required String user_id}) async {
    try {
      emit(ExpireSoonStockListLoading());
      final response = await apiRepository.stockList(user_id,'expiring');
      final list = response.map((json) => InvoiceItem.fromJson(json)).toList();
      emit(ExpireSoonStockListLoaded(stockList: list));
    } catch (e) {
      emit(ExpireSoonStockListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchSaleList({required String user_id}) async {
    try {
      emit(SaleListLoading());
      final response = await apiRepository.saleList(user_id);
      final data = response['bills'] as List;
      final list = data.map((json) => SaleModel.fromJson(json)).toList();
      emit(SaleListLoaded(saleList: list));
    } catch (e) {
      emit(SaleListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> SaleEdit({required String billingid,required OrderPlaceModel orderPlaceModel}) async {
    try {
      emit(SaleEditLoading());
      final response = await apiRepository.saleEdit(billingid,orderPlaceModel);
      final data = response['message'];
      final billing_id = response['billing_id'];

      emit(SaleEditLoaded(message: data, billing_id: billing_id));
    } catch (e) {
      emit(SaleEditError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> SaleDelete({required String billing_id}) async {
    try {
      emit(SaleDeleteLoading());
      final response = await apiRepository.saleDelete(billing_id);
      final message = response['message'];
      emit(SaleDeleteLoaded(message: message));
    } catch (e) {
      emit(SaleDeleteError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchLedgerList({required String user_id}) async {
    try {
      emit(LedgerListLoading());
      final response = await apiRepository.leadgerList(user_id);
      final data = response['data'] as List;
      final list = data.map((json) => LedgerModel.fromJson(json)).toList();
      emit(LedgerListLoaded(leadgerList: list));
    } catch (e) {
      emit(LedgerListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StorePayment({required Payment payment}) async {
    try {
      emit(StorePaymentLoading());
      final response = await apiRepository.payment(payment,'storepayment');
      final message = response['message'];
      emit(StorePaymentLoaded(message: message));
    } catch (e) {
      emit(StorePaymentError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> UpdatePayment({required Payment payment}) async {
    try {
      emit(UpdatePaymentLoading());
      final response = await apiRepository.payment(payment,'updatepayment');
      final message = response['message'];
      emit(UpdatePaymentLoaded(message: message));
    } catch (e) {
      emit(UpdatePaymentError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> DeletePayment({required String id}) async {
    try {
      emit(DeletePaymentLoading());
      final response = await apiRepository.paymentDelete(id);
      final message = response['message'];
      emit(DeletePaymentLoaded(message: message));
    } catch (e) {
      emit(DeletePaymentError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StockReturnAdd({required PurchaseReturnModel returnModel}) async {
    try {
      emit(StockReturnAddLoading());
      final response = await apiRepository.stockReturn(returnModel,'store');
      final success = response['success'];
      emit(StockReturnAddLoaded(success: success));
    } catch (e) {
      emit(StockReturnAddError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StockReturnEdit({required PurchaseReturnModel returnModel}) async {
    try {
      emit(StockReturnEditLoading());
      final response = await apiRepository.stockReturn(returnModel,'update');
      final success = response['success'];
      emit(StockReturnEditLoaded(success: success));
    } catch (e) {
      emit(StockReturnEditError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StockReturnDelete({required String id}) async {
    try {
      emit(StockReturnDeleteLoading());
      final response = await apiRepository.stockReturnDelete(id);
      final success = response['success'];
      emit(StockReturnDeleteLoaded(success: success));
    } catch (e) {
      emit(StockReturnDeleteError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchStockReturnList({required String store_id}) async {
    try {
      emit(StockReturnListLoading());
      final response = await apiRepository.fetchList(store_id,'stockist-returns');
      final data = response['data'] as List;
      final list = data.map((json) => PurchaseReturnModel.fromJson(json)).toList();
      emit(StockReturnListLoaded(returnList: list));
    } catch (e) {
      emit(StockReturnListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> GetInvoiceDetail({required String invoice_id,required String store_id}) async {
    try {
      emit(GetInvoiceDetailLoading());
      final response = await apiRepository.invoiceDetail(invoice_id,store_id);
      final model = Invoice.fromJson_StockReturn(response);
      emit(GetInvoiceDetailLoaded(invoiceModel: model));
    } catch (e) {
      emit(GetInvoiceDetailError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> GetSaleBillDetail({required String bill_id,required String store_id}) async {
    try {
      emit(GetSaleBillDetailLoading());
      final response = await apiRepository.billDetail(bill_id,store_id);
      final model = Billing.fromJson(response);
      emit(GetSaleBillDetailLoaded(billingModel: model));
    } catch (e) {
      emit(GetSaleBillDetailError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> SaleReturnAdd({required SaleReturnRequest returnModel}) async {
    try {
      emit(SaleReturnAddLoading());
      final response = await apiRepository.saleReturn(returnModel,'store');
      final success = response['success'];
      emit(SaleReturnAddLoaded(success: success));
    } catch (e) {
      emit(SaleReturnAddError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> SaleReturnEdit({required SaleReturnRequest returnModel}) async {
    try {
      emit(SaleReturnEditLoading());
      final response = await apiRepository.saleReturn(returnModel,'update');
      final success = response['success'];
      emit(SaleReturnEditLoaded(success: success));
    } catch (e) {
      emit(SaleReturnEditError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchSaleReturnList({required String store_id}) async {
    try {
      emit(SaleReturnListLoading());
      final response = await apiRepository.fetchList(store_id,'customer-returns');
      final data = response['data'] as List;
      final list = data.map((json) => CustomerReturnsResponse.fromJson(json)).toList();
      emit(SaleReturnListLoaded(billList: list));
    } catch (e) {
      emit(SaleReturnListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> ExpenseAdd({required String store_id,required String title,required String amount,required String expanse_date,required String note}) async {
    try {
      emit(ExpenseAddLoading());
      final response = await apiRepository.Expense(storeId: store_id,title: title,amount: amount,
          expanseDate: expanse_date,note: note,apiName: 'store');
      final success = response['status'];
      emit(ExpenseAddLoaded(success: success));
    } catch (e) {
      emit(ExpenseAddError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> ExpenseEdit({required String id,required String store_id,required String title,required String amount,required String expanse_date,required String note}) async {
    try {
      emit(ExpenseEditLoading());
      final response = await apiRepository.Expense(id: id,storeId: store_id,title: title,amount: amount,
          expanseDate: expanse_date,note: note,apiName: 'update');
      final success = response['status'];
      emit(ExpenseEditLoaded(success: success));
    } catch (e) {
      emit(ExpenseEditError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchExpenseList({required String store_id}) async {
    try {
      emit(ExpenseListLoading());
      final response = await apiRepository.fetchList(store_id,'expense');
      final data = response['data'] as List;
      final list = data.map((json) => ExpenseResponse.fromJson(json)).toList();
      emit(ExpenseListLoaded(list: list));
    } catch (e) {
      emit(ExpenseListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchStaffList({required String store_id}) async {
    try {
      emit(StaffListLoading());
      final response = await apiRepository.fetchList(store_id,'staff');
      final data = response['data'] as List;
      final list = data.map((json) => StaffModel.fromJson(json)).toList();
      emit(StaffListLoaded(staffList: list));
    } catch (e) {
      emit(StaffListError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StaffEdit({
    required String id,
    required String name,
    required String email,
    required String phone_number,
    required String gender,
    required String dob,
    required String address,
    required String password,
    required String password_confirmation,
    required String store_id,
    required String status,}) async {
    try {
      emit(StaffEditLoading());
      final response = await apiRepository.Staff(id: id,name:  name,email:  email,
        phoneNumber: phone_number,gender:  gender, dob: dob, address: address, password: password,
        passwordConfirmation: password_confirmation, storeId: store_id, status: status,);
      final data = response['message'];
      final status1 = response['status'];
      emit(StaffEditLoaded(message: data,status:status1));
    } catch (e) {
      emit(StaffEditError('Error: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StaffAdd({
    required String name,
    required String email,
    required String phone_number,
    required String gender,
    required String dob,
    required String address,
    required String password,
    required String password_confirmation,
    required String store_id,}) async {
    try {
      emit(StaffAddLoading());
      final response = await apiRepository.Staff(name:  name,email:  email,
        phoneNumber: phone_number,gender:  gender, dob: dob, address: address, password: password,
        passwordConfirmation: password_confirmation, storeId: store_id);
      final message = response['message'];
      final status = response['status'];
      emit(StaffAddLoaded(message: message,status:status ));
    } catch (e) {
      emit(StaffAddError('Error: $e'));
    }
  }
}
