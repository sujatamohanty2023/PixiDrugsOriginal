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
class DoctorRegistrationLoading extends ApiState {}

class DoctorRegistrationLoaded extends ApiState {
  final String message;

  DoctorRegistrationLoaded({required this.message});
}

class DoctorRegistrationError extends ApiState {
  final String error;
  DoctorRegistrationError(this.error);
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
class DoctorProfileLoading extends ApiState {}

class DoctorProfileLoaded extends ApiState {
  final DoctorProfileModel doctorModel;

  DoctorProfileLoaded({required this.doctorModel});
}

class DoctorProfileError extends ApiState {
  final String error;
  DoctorProfileError(this.error);
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
