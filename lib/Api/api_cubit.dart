// api_cubit.dart

import 'package:pixidrugs/constant/all.dart';

class ApiCubit extends Cubit<ApiState> {
  final ApiRepository apiRepository;

  ApiCubit(this.apiRepository) : super(ApiInitial());

//------------------------------------------------------------------------------------
  Future<void> login(
      {required String mobile, required String fcm_token,required String role}) async {
    try {
      emit(LoginLoading());
      final response = await apiRepository.loginUser(mobile, fcm_token,role);

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
      final data = response['stock'] as List;
      final list = data.map((json) => InvoiceItem.fromJson(json)).toList();
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
      final data = response['stock'] as List;
      final list = data.map((json) => InvoiceItem.fromJson(json)).toList();
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
      final data = response['stock'] as List;
      final list = data.map((json) => InvoiceItem.fromJson(json)).toList();
      emit(ExpireSoonStockListLoaded(stockList: list));
    } catch (e) {
      emit(ExpireSoonStockListError('Failed to load invoice: $e'));
    }
  }
}
