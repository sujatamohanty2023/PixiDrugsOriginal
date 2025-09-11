import '../customWidget/PaymentTypeWidget.dart';
import 'all.dart';

class AppString {
  static String baseUrl = 'https://pixidrugs.com/';

  static String loginText = 'Login with Mobile Number';
  static String logindesc = 'Enter your mobile number to receive an OTP';
  static String enterMobileNo="Enter mobile number";
  static String continueText="Continue";
  static String get_started="Get Started";
  static String verifyOtp="OTP Verification";
  static String otpdesc='Enter the 6-digit code we sent to verify your number and continue with secure account.';
  static String verify_continue="Verify & Continue";


  static String Rupees = "₹";
  static String Thank_you = "Thank You!";
  static String Done = "Done";

  static String storeName = "Store Name";
  static String ownerName = 'Owner Name';
  static String email = 'Email';
  static String phone = 'Phone';
  static String storeAddress = 'Store Address';
  static String enterNumber = 'Enter your phone number';
  static String enterGst = 'Enter your GSTIN NO.';
  static String enterRegNo = 'Enter your Licence NO.';
  static String enterEmail = 'Enter your email';
  static String upDate = 'Update';


  static List<PaymentPopupMenuItemData> paymentTypes = [
    PaymentPopupMenuItemData(value: 'Cash', icon: Icons.money),
    PaymentPopupMenuItemData(value: 'Card', icon: Icons.credit_card_outlined),
    PaymentPopupMenuItemData(value: 'Bank', icon: Icons.account_balance),
    PaymentPopupMenuItemData(value: 'UPI', icon: Icons.qr_code),
    PaymentPopupMenuItemData(value: 'Due', icon: Icons.calendar_month),
  ];
  static List<PaymentPopupMenuItemData> paymentReason = [
    PaymentPopupMenuItemData(value: 'All', icon: Icons.all_inbox),
    PaymentPopupMenuItemData(value: 'Credit', icon: Icons.arrow_downward_rounded),
    PaymentPopupMenuItemData(value: 'Debit', icon: Icons.arrow_upward_rounded),
  ];

}
