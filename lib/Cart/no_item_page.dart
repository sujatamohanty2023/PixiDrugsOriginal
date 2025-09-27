
import '../../constant/all.dart';

class NoItemPage extends StatelessWidget {
  final VoidCallback? onTap;
  var tittle;
  var description;
  var button_tittle;
  var image;

  NoItemPage({
    Key? key,
    required this.onTap,
    required this.image,
    required this.tittle,
    required this.description,
    required this.button_tittle
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration or Icon
              Container(
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryDark, // Light blue background
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SvgPicture.asset(
                    color: AppColors.loginbg,
                    image,
                    height: 130,
                    width: 130,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Text for "Cart is Empty"
              MyTextfield.textStyle_w600(
                  tittle, AppUtils.size_25, AppColors.loginbg),

              SizedBox(height: 15),
              // Subtitle Text
              MyTextfield.textStyle_w200(
                  description, AppUtils.size_18, AppColors.kGreyColor800),
              SizedBox(height: 30),
              // Gradient Button to Go Back to Shopping
              button_tittle.toString().isNotEmpty
                  ? GestureDetector(
                      onTap: onTap,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.kPrimaryLight),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: MyTextfield.textStyle_w600(button_tittle,
                              AppUtils.size_16, AppColors.kPrimaryLight),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
