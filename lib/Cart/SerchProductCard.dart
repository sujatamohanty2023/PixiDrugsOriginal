
import 'package:PixiDrugs/constant/all.dart';

class SerchProductCard extends StatefulWidget {
  final InvoiceItem item;
  const SerchProductCard({super.key, required this.item});

  @override
  State<SerchProductCard> createState() => _SerchProductCardState();
}

class _SerchProductCardState extends State<SerchProductCard> {
  late InvoiceItem item;

  @override
  void initState() {
    super.initState();
    item=widget.item;
  }
  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [

          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(12), // Rounded corners
              border: Border.all(
                color: AppColors.kPrimaryDark, // Border color
                width: 1, // Border width
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Row(
                    children: [
                      _buildProductImage(),
                      const SizedBox(width: 10),
                      Expanded(child: _buildProductDetails(context, cartCubit)),
                    ],
                  ),
                  _buildQuantityControls(context, cartCubit),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Divider(
          //   color: AppColors.kBlackColor900.withOpacity(0.1),
          //   thickness: 0.5,
          // ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    String initials = item.product.length >= 2 ? item.product.substring(0, 2).toUpperCase() : item.product.toUpperCase();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kPrimaryDark,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.kPrimaryLight,width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: MyTextfield.textStyle_w800(initials, 20, AppColors.kPrimary),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, CartCubit cartCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextfield.textStyle_w600(item.product, 18, Colors.black),
        MyTextfield.textStyle_w200('Batch No.${item.batch}', 12, AppColors.kPrimary, maxLines: 2),
        MyTextfield.textStyle_w200(item.composition, 12, Colors.grey[600]!, maxLines: 2),
        const SizedBox(height: 4),
        MyTextfield.textStyle_w600(
          "${AppString.Rupees}${item.mrp}",
          16,
          Colors.green,
        ),
        SizedBox(height: 2),

      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartCubit cartCubit) {
    return Positioned(
      bottom: 5,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final quantity = state.barcodeCartItems
                .firstWhere(
                  (e) => e.id == item.id,
              orElse: () => item.copyWith(qty: 0),
            )
                .qty;

            if (quantity == 0) {
              return GestureDetector(
                onTap: () {
                  cartCubit.addToCart(item, 1, type: CartType.barcode);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MyTextfield.textStyle_w600("ADD", 14, Colors.white),
                ),
              );
            } else {
              return Row(
                children: [
                  _buildQuantityButton(
                    type: 0,
                    icon: Icons.remove,
                    onTap: () {
                      if (quantity <= 1) {
                        cartCubit.removeFromCart(item.id, type: CartType.barcode);
                      } else {
                        cartCubit.decrementQuantity(item.id, type: CartType.barcode);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  MyTextfield.textStyle_w600(quantity.toString(), 18, Colors.black87),
                  const SizedBox(width: 8),
                  _buildQuantityButton(
                    type: 1,
                    icon: Icons.add,
                    onTap: () {
                      cartCubit.incrementQuantity(item.id, type: CartType.barcode);
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required int type,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.kPrimary,
          borderRadius:
          type==0?const BorderRadius.only(
              topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)):
          const BorderRadius.only(
              topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildQuantityDisplay() {
    return Builder(
      builder: (context) {
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final quantity = state.barcodeCartItems.firstWhere(
                  (e) => e.id == item.id,
              orElse: () => item,
            ).qty;

            return MyTextfield.textStyle_w600(quantity.toString(), 18, Colors.black87);
          },
        );
      },
    );
  }
}
