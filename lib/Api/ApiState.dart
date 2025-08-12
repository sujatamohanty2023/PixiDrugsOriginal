import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/SaleReturn/BillingModel.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../Expense/ExpenseResponse.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../Staff/StaffModel.dart';
import '../StockReturn/PurchaseReturnModel.dart';

abstract class ApiState {}

class ApiInitial extends ApiState {}

//--------------------------------------------------------------------
class LoginLoading extends ApiState {}

class LoginLoaded extends ApiState {
  LoginResponse loginResponse;

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
  final UserProfileResponse userModel;

  UserProfileLoaded({required this.userModel});
}

class UserProfileError extends ApiState {
  final String error;
  UserProfileError(this.error);
}

//--------------------------------------------------------------------
class EditProfileLoading extends ApiState {}

class EditProfileLoaded extends ApiState {
  final UserProfile userModel;
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
  final List<InvoiceItem> list;
  final String source;
  BarcodeScanLoaded({required this.list, this.source = 'scan'});
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
  final String status;
  InvoiceEditLoaded({required this.message,required this.status});
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
  final String status;
  InvoiceAddLoaded({required this.message,required this.status});
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
  final String billing_id;

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
//--------------------------------------------------------------------
class StockReturnEditLoading extends ApiState {}

class StockReturnEditLoaded extends ApiState {
  final bool success;
  StockReturnEditLoaded({required this.success});
}

class StockReturnEditError extends ApiState {
  final String error;
  StockReturnEditError(this.error);
}
//--------------------------------------------------------------------
class StockReturnDeleteLoading extends ApiState {}

class StockReturnDeleteLoaded extends ApiState {
  final bool success;
  StockReturnDeleteLoaded({required this.success});
}

class StockReturnDeleteError extends ApiState {
  final String error;
  StockReturnDeleteError(this.error);
}
//--------------------------------------------------------------------
class StockReturnAddLoading extends ApiState {}

class StockReturnAddLoaded extends ApiState {
  final bool success;
  StockReturnAddLoaded({required this.success});
}

class StockReturnAddError extends ApiState {
  final String error;
  StockReturnAddError(this.error);
}
//--------------------------------------------------------------------
class StockReturnListLoading extends ApiState {}

class StockReturnListLoaded extends ApiState {
  final List<PurchaseReturnModel> returnList;
  StockReturnListLoaded({required this.returnList});
}

class StockReturnListError extends ApiState {
  final String error;
  StockReturnListError(this.error);
}
//--------------------------------------------------------------------
class GetInvoiceDetailLoading extends ApiState {}

class GetInvoiceDetailLoaded extends ApiState {
  final Invoice invoiceModel;
  GetInvoiceDetailLoaded({required this.invoiceModel});
}

class GetInvoiceDetailError extends ApiState {
  final String error;
  GetInvoiceDetailError(this.error);
}
//--------------------------------------------------------------------
class GetSaleBillDetailLoading extends ApiState {}

class GetSaleBillDetailLoaded extends ApiState {
  final Billing billingModel;
  GetSaleBillDetailLoaded({required this.billingModel});
}

class GetSaleBillDetailError extends ApiState {
  final String error;
  GetSaleBillDetailError(this.error);
}
//--------------------------------------------------------------------
class SaleReturnAddLoading extends ApiState {}

class SaleReturnAddLoaded extends ApiState {
  final bool success;
  SaleReturnAddLoaded({required this.success});
}

class SaleReturnAddError extends ApiState {
  final String error;
  SaleReturnAddError(this.error);
}
//--------------------------------------------------------------------
class SaleReturnEditLoading extends ApiState {}

class SaleReturnEditLoaded extends ApiState {
  final bool success;
  SaleReturnEditLoaded({required this.success});
}

class SaleReturnEditError extends ApiState {
  final String error;
  SaleReturnEditError(this.error);
}
//--------------------------------------------------------------------
class SaleReturnListLoading extends ApiState {}

class SaleReturnListLoaded extends ApiState {
  final List<CustomerReturnsResponse> billList;
  SaleReturnListLoaded({required this.billList});
}

class SaleReturnListError extends ApiState {
  final String error;
  SaleReturnListError(this.error);
}
//--------------------------------------------------------------------
class ExpenseAddLoading extends ApiState {}

class ExpenseAddLoaded extends ApiState {
  final bool success;
  ExpenseAddLoaded({required this.success});
}

class ExpenseAddError extends ApiState {
  final String error;
  ExpenseAddError(this.error);
}
//--------------------------------------------------------------------
class ExpenseEditLoading extends ApiState {}

class ExpenseEditLoaded extends ApiState {
  final bool success;
  ExpenseEditLoaded({required this.success});
}

class ExpenseEditError extends ApiState {
  final String error;
  ExpenseEditError(this.error);
}
//--------------------------------------------------------------------
class ExpenseListLoading extends ApiState {}

class ExpenseListLoaded extends ApiState {
  final List<ExpenseResponse> list;
  ExpenseListLoaded({required this.list});
}

class ExpenseListError extends ApiState {
  final String error;
  ExpenseListError(this.error);
}
//--------------------------------------------------------------------
class StaffAddLoading extends ApiState {}

class StaffAddLoaded extends ApiState {
  final String message;
  final String status;
  StaffAddLoaded({required this.message,required this.status});
}

class StaffAddError extends ApiState {
  final String error;
  StaffAddError(this.error);
}
//--------------------------------------------------------------------
class StaffEditLoading extends ApiState {}

class StaffEditLoaded extends ApiState {
  final String message;
  final String status;
  StaffEditLoaded({required this.message,required this.status});
}

class StaffEditError extends ApiState {
  final String error;
  StaffEditError(this.error);
}
//--------------------------------------------------------------------
class StaffListLoading extends ApiState {}

class StaffListLoaded extends ApiState {
  final List<StaffModel> staffList;
  StaffListLoaded({required this.staffList});
}

class StaffListError extends ApiState {
  final String error;
  StaffListError(this.error);
}