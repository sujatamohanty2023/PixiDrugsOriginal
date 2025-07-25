// api_cubit.dart

import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/Ledger/Payment.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/return/ReturnDataModel.dart';

import '../return/PurchaseReturn.dart';

class ApiCubit extends Cubit<ApiState> {
  final ApiRepository apiRepository;

  ApiCubit(this.apiRepository) : super(ApiInitial());

//------------------------------------------------------------------------------------
  Future<void> login(
      {required String mobile, required String fcm_token}) async {
    try {
      emit(LoginLoading());
      final response = await apiRepository.loginUser(mobile, fcm_token);

      final loginModel = LoginModel.fromJson(response);
      emit(LoginLoaded(loginResponse: loginModel));
    } catch (e) {
      emit(LoginError('Failed to load login response: $e'));
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
      emit(BannerError('Failed to load doctors: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> GetUserData({required String userId}) async {
    try {
      emit(UserProfileLoading());
      final response = await apiRepository.GetUserProfile(userId);
      final data = response['user'];
      final model = UserProfileModel.fromJson(data);
      emit(UserProfileLoaded(userModel: model));
    } catch (e) {
      emit(UserProfileError('Failed to load user profile: $e'));
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
      final model = UserProfileModel.fromJson(data);
      emit(EditProfileLoaded(userModel: model, message: message));
    } catch (e) {
      emit(EditProfileError('Failed to edit user profile: $e'));
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
      emit(UpdateFCMTokenError('Failed to Add Records: $e'));
    }
  }

  //------------------------------------------------------------------------------------
  Future<void> BarcodeScan({required String code}) async {
    try {
      emit(BarcodeScanLoading());
      final response = await apiRepository.barcodeScan(code);
      final json = response['product'];
      final model =  InvoiceItem.fromJson(json);
      emit(BarcodeScanLoaded(model: model));
    } catch (e) {
      emit(BarcodeScanError('Failed to fetch data: $e'));
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
      emit(OrderPlaceError('Failed to checkout: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> InvoiceAdd({required Invoice invoice}) async {
    try {
      emit(InvoiceAddLoading());
      final response = await apiRepository.post_Invoice(invoice);
      final message = response['message'];
      emit(InvoiceAddLoaded(message: message));
    } catch (e) {
      emit(InvoiceAddError('Failed to fetch data: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> InvoiceEdit({required Invoice invoice}) async {
    try {
      emit(InvoiceEditLoading());
      final response = await apiRepository.edit_Invoice(invoice);
      final message = response['message'];
      emit(InvoiceEditLoaded(message: message));
    } catch (e) {
      emit(InvoiceEditError('Failed to edit data: $e'));
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
      emit(InvoiceDeleteError('Failed to Delete data: $e'));
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
      emit(InvoiceListError('Failed to load invoice: $e'));
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
      emit(StockListError('Failed to load invoice: $e'));
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
      emit(ExpiredStockListError('Failed to load invoice: $e'));
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
      emit(ExpireSoonStockListError('Failed to load invoice: $e'));
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
      emit(SaleListError('Failed to load sale: $e'));
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
      emit(SaleEditError('Failed to checkout: $e'));
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
      emit(SaleDeleteError('Failed to Delete data: $e'));
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
      emit(LedgerListError('Failed to load ledger: $e'));
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
      emit(StorePaymentError('Failed to Store data: $e'));
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
      emit(UpdatePaymentError('Failed to Update data: $e'));
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
      emit(DeletePaymentError('Failed to Delete data: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StockReturnAdd({required PurchaseReturn returnModel}) async {
    try {
      emit(StockReturnAddLoading());
      final response = await apiRepository.stockReturn(returnModel,'store');
      final success = response['success'];
      emit(StockReturnAddLoaded(success: success));
    } catch (e) {
      emit(StockReturnAddError('Failed to fetch data: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> StockReturnEdit({required PurchaseReturn returnModel}) async {
    try {
      emit(StockReturnEditLoading());
      final response = await apiRepository.stockReturn(returnModel,'update');
      final success = response['success'];
      emit(StockReturnEditLoaded(success: success));
    } catch (e) {
      emit(StockReturnEditError('Failed to edit data: $e'));
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
      emit(StockReturnDeleteError('Failed to Delete data: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> fetchStockReturnList({required String store_id}) async {
    try {
      emit(StockReturnListLoading());
      final response = await apiRepository.stockReturnList(store_id);
      final data = response['data'] as List;
      final list = data.map((json) => ReturnDataModel.fromJson(json)).toList();
      emit(StockReturnListLoaded(returnList: list));
    } catch (e) {
      emit(StockReturnListError('Failed to load returnList: $e'));
    }
  }
  //------------------------------------------------------------------------------------
  Future<void> GetInvoiceDetail({required String invoice_id}) async {
    try {
      emit(GetInvoiceDetailLoading());
      final response = await apiRepository.invoiceDetail(invoice_id);
      final model = Invoice.fromJson_StockReturn(response);
      emit(GetInvoiceDetailLoaded(invoiceModel: model));
    } catch (e) {
      emit(GetInvoiceDetailError('Failed to load invoice: $e'));
    }
  }
}
