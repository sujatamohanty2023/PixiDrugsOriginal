import 'package:pixidrugs/Ledger/LedgerModel.dart';
import 'package:pixidrugs/SaleList/sale_model.dart';
import 'package:pixidrugs/constant/all.dart';

abstract class ApiState {}

class ApiInitial extends ApiState {}

//--------------------------------------------------------------------
class LoginLoading extends ApiState {}

class LoginLoaded extends ApiState {
  LoginModel loginResponse;

  LoginLoaded({required this.loginResponse});
}

class LoginError extends ApiState {
  final String error;
  LoginError(this.error);
}
//--------------------------------------------------------------------
class BannerLoading extends ApiState {}

class BannerLoaded extends ApiState {
  final List<BannerModel> banner;

  BannerLoaded({required this.banner});
}

class BannerError extends ApiState {
  final String error;
  BannerError(this.error);
}
//--------------------------------------------------------------------
class UserProfileLoading extends ApiState {}

class UserProfileLoaded extends ApiState {
  final UserProfileModel userModel;

  UserProfileLoaded({required this.userModel});
}

class UserProfileError extends ApiState {
  final String error;
  UserProfileError(this.error);
}

//--------------------------------------------------------------------
class EditProfileLoading extends ApiState {}

class EditProfileLoaded extends ApiState {
  final UserProfileModel userModel;
  final String message;

  EditProfileLoaded({required this.userModel, required this.message});
}

class EditProfileError extends ApiState {
  final String error;
  EditProfileError(this.error);
}
//--------------------------------------------------------------------
class UpdateFCMTokenLoading extends ApiState {}

class UpdateFCMTokenLoaded extends ApiState {
  final String message;
  UpdateFCMTokenLoaded({required this.message});
}

class UpdateFCMTokenError extends ApiState {
  final String error;
  UpdateFCMTokenError(this.error);
}
//--------------------------------------------------------------------
class BarcodeScanLoading extends ApiState {}

class BarcodeScanLoaded extends ApiState {
  final InvoiceItem model;
  BarcodeScanLoaded({required this.model});
}

class BarcodeScanError extends ApiState {
  final String error;
  BarcodeScanError(this.error);
}

//--------------------------------------------------------------------
class OrderPlaceLoading extends ApiState {}

class OrderPlaceLoaded extends ApiState {
  final String message;
  final SaleModel saleModel;

  OrderPlaceLoaded({required this.message,required this.saleModel});
}

class OrderPlaceError extends ApiState {
  final String error;
  OrderPlaceError(this.error);
}
//--------------------------------------------------------------------
class InvoiceEditLoading extends ApiState {}

class InvoiceEditLoaded extends ApiState {
  final String message;
  InvoiceEditLoaded({required this.message});
}

class InvoiceEditError extends ApiState {
  final String error;
  InvoiceEditError(this.error);
}
//--------------------------------------------------------------------
class InvoiceDeleteLoading extends ApiState {}

class InvoiceDeleteLoaded extends ApiState {
  final String message;
  InvoiceDeleteLoaded({required this.message});
}

class InvoiceDeleteError extends ApiState {
  final String error;
  InvoiceDeleteError(this.error);
}
//--------------------------------------------------------------------
class InvoiceAddLoading extends ApiState {}

class InvoiceAddLoaded extends ApiState {
  final String message;
  InvoiceAddLoaded({required this.message});
}

class InvoiceAddError extends ApiState {
  final String error;
  InvoiceAddError(this.error);
}
//--------------------------------------------------------------------
class InvoiceListLoading extends ApiState {}

class InvoiceListLoaded extends ApiState {
  final List<Invoice> invoiceList;
  InvoiceListLoaded({required this.invoiceList});
}

class InvoiceListError extends ApiState {
  final String error;
  InvoiceListError(this.error);
}
//--------------------------------------------------------------------
class StockListLoading extends ApiState {}

class StockListLoaded extends ApiState {
  final List<InvoiceItem> stockList;
  StockListLoaded({required this.stockList});
}

class StockListError extends ApiState {
  final String error;
  StockListError(this.error);
}
//--------------------------------------------------------------------
class ExpiredStockListLoading extends ApiState {}

class ExpiredStockListLoaded extends ApiState {
  final List<InvoiceItem> stockList;
  ExpiredStockListLoaded({required this.stockList});
}

class ExpiredStockListError extends ApiState {
  final String error;
  ExpiredStockListError(this.error);
}
//--------------------------------------------------------------------
class ExpireSoonStockListLoading extends ApiState {}

class ExpireSoonStockListLoaded extends ApiState {
  final List<InvoiceItem> stockList;
  ExpireSoonStockListLoaded({required this.stockList});
}

class ExpireSoonStockListError extends ApiState {
  final String error;
  ExpireSoonStockListError(this.error);
}
//--------------------------------------------------------------------
class SaleListLoading extends ApiState {}

class SaleListLoaded extends ApiState {
  final List<SaleModel> saleList;
  SaleListLoaded({required this.saleList});
}

class SaleListError extends ApiState {
  final String error;
  SaleListError(this.error);
}
//--------------------------------------------------------------------
class SaleEditLoading extends ApiState {}

class SaleEditLoaded extends ApiState {
  final String message;
  final int billing_id;

  SaleEditLoaded({required this.message, required this.billing_id});
}

class SaleEditError extends ApiState {
  final String error;
  SaleEditError(this.error);
}
//--------------------------------------------------------------------
class SaleDeleteLoading extends ApiState {}

class SaleDeleteLoaded extends ApiState {
  final String message;
  SaleDeleteLoaded({required this.message});
}

class SaleDeleteError extends ApiState {
  final String error;
  SaleDeleteError(this.error);
}
//--------------------------------------------------------------------
class LedgerListLoading extends ApiState {}

class LedgerListLoaded extends ApiState {
  final List<LedgerModel> leadgerList;
  LedgerListLoaded({required this.leadgerList});
}

class LedgerListError extends ApiState {
  final String error;
  LedgerListError(this.error);
}
//--------------------------------------------------------------------
class StorePaymentLoading extends ApiState {}

class StorePaymentLoaded extends ApiState {
  final String message;
  StorePaymentLoaded({required this.message});
}

class StorePaymentError extends ApiState {
  final String error;
  StorePaymentError(this.error);
}
//--------------------------------------------------------------------
class UpdatePaymentLoading extends ApiState {}

class UpdatePaymentLoaded extends ApiState {
  final String message;
  UpdatePaymentLoaded({required this.message});
}

class UpdatePaymentError extends ApiState {
  final String error;
  UpdatePaymentError(this.error);
}
//--------------------------------------------------------------------
class DeletePaymentLoading extends ApiState {}

class DeletePaymentLoaded extends ApiState {
  final String message;
  DeletePaymentLoaded({required this.message});
}

class DeletePaymentError extends ApiState {
  final String error;
  DeletePaymentError(this.error);
}