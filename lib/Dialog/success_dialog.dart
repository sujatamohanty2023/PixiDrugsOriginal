import 'package:pixidrugs/Cart/ReceiptPrinterPage.dart';
import 'package:pixidrugs/SaleList/sale_model.dart';
import 'package:pixidrugs/constant/all.dart';

class SuccessDialog extends StatefulWidget {
  SvgPicture image;
  String tittle, msg;
  SaleModel sale;

  SuccessDialog(this.sale,this.image, this.tittle, this.msg, {super.key});

  @override
  _SuccessDialogState createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.myGradient, // Background color changed to white
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2), // Light green background
                shape: BoxShape.circle, // Circular shape
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: widget.image,
              ),
            ),
            SizedBox(height: 20),
            MyTextfield.textStyle_w600(
                AppString.Thank_you, AppUtils.size_25, Colors.teal),
            SizedBox(height: 10),
            MyTextfield.textStyle_w600(
                widget.tittle, AppUtils.size_14, Colors.teal),
            SizedBox(height: 20),
            MyTextfield.textStyle_w600(
                widget.msg, AppUtils.size_14, Colors.black54),
            SizedBox(height: 50),
            MyElevatedButton(
              onPressed: _onButtonPrintPressed,
              buttonText: AppString.Done,
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  void _onButtonPrintPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.kWhiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.70,
        minChildSize: 0.60,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ReceiptPrinterPage(
            sale: widget.sale,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}
