
import 'package:PixiDrugs/constant/all.dart';

class addressWidget extends StatefulWidget {
  final String name,address,phone;
  bool isSaleCart;
  Future<void> Function() tap;

  addressWidget({
    Key? key,
    this.name = '',
    this.address = '',
    this.phone = '',
    this.isSaleCart=false,
    required this.tap,
  }) : super(key: key);

  @override
  _addressWidgetState createState() => _addressWidgetState();
}

class _addressWidgetState extends State<addressWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(
          color: AppColors.kPrimaryDark, // Border color
          width: 1, // Border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.kPrimaryDark,
              child:
              SvgPicture.asset(AppImages.home_address, height: 35, width: 35),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  MyTextfield.textStyle_w600('${widget.name}', 16, AppColors.kPrimary),
                  MyTextfield.textStyle_w400('${widget.phone}', 14, Colors.teal),
                  MyTextfield.textStyle_w400('${widget.address}', 12, Colors.grey[700]!,maxLines: true),
                ],
              ),
            ),
            widget.isSaleCart?GestureDetector(
              onTap: widget.tap,
              child: MyTextfield.textStyle_w600("Change", 14, Colors.deepOrange),
            ):SizedBox(),
          ],
        ),
      ),
    );
  }
}
