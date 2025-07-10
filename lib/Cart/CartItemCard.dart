
import 'package:pixidrugs/constant/all.dart';

class CartItemCard extends StatefulWidget {
  final InvoiceItem item;
  final bool barcodeScan,edit;
  final VoidCallback? onRemove,onUpdate;
  const CartItemCard({super.key, required this.item, this.barcodeScan = false,this.edit = false,
    this.onRemove,this.onUpdate});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late TextEditingController discController;
  late InvoiceItem item;
  late bool barcodeScan;

  @override
  void initState() {
    super.initState();
    item=widget.item;
    barcodeScan=widget.barcodeScan;
    discController = TextEditingController(text: widget.item.discountSale);
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.discountSale != widget.item.discountSale) {
      discController.text = widget.item.discountSale;
    }
  }

  @override
  void dispose() {
    discController.dispose();
    super.dispose();
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
                  _buildRemoveIcon(context, cartCubit),
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

  Widget _buildRemoveIcon(BuildContext context, CartCubit cartCubit) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => _showRemoveBottomSheet(context, cartCubit),
        child: Icon(Icons.clear, color: Colors.grey[400], size: 20),
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
        MyTextfield.textStyle_w200(item.composition, 12, Colors.grey[600]!, maxLines: 2),
        const SizedBox(height: 4),
        MyTextfield.textStyle_w600(
          "${AppString.Rupees}${item.mrp}",
          16,
          Colors.green,
        ),
        SizedBox(height: 2),
        Row(
          children: [
            SizedBox(
              height: 35,
              width: 80,
              child: MyEdittextfield(
                controller: discController,
                hintText: "Discount",
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final discount = double.tryParse(val) ?? 0.0;
                  if(!widget.edit) {
                    item.discount=discount.toString();
                    cartCubit.updateItemDiscount(
                      item.id,
                      discount,
                      type: barcodeScan ? CartType.barcode : CartType.main,
                      discountType: item.discountType, // default for now
                    );
                  }else{
                    item.discount=discount.toString();
                    widget.onUpdate?.call();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<DiscountType>(
              value: item.discountType,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (DiscountType? newType) {
                if (newType != null) {
                if(!widget.edit) {
                  cartCubit.updateItemDiscount(
                    item.id,
                    double.tryParse(discController.text) ?? 0.0,
                    type: barcodeScan ? CartType.barcode : CartType.main,
                    discountType: newType,
                  );
                }else{
                  item.discountType=newType;
                  widget.onUpdate?.call();
                }
              }
              },
              items: DiscountType.values.map((DiscountType type) {
                return DropdownMenuItem<DiscountType>(
                  value: type,
                  child: Text(type == DiscountType.flat ? '₹ Flat' : '% Off'),
                );
              }).toList(),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartCubit cartCubit) {
    return Positioned(
      bottom: 5,
      right: 0,
      child:  Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Row(
          children: [
            _buildQuantityButton(
              type:0,
              icon: Icons.remove,
              onTap: () {
                if(!widget.edit) {
                  final qty = cartCubit.getQuantity(item.id,
                      type: barcodeScan ? CartType.barcode : CartType.main);

                  if (qty <= 1) {
                    cartCubit.removeFromCart(item.id,
                        type: barcodeScan ? CartType.barcode : CartType.main);
                  } else {
                    cartCubit.decrementQuantity(item.id,
                        type: barcodeScan ? CartType.barcode : CartType.main);
                  }
                }else{
                  if (item.qty <= 1) {
                    widget.onRemove?.call();
                  } else {
                    setState(() {
                      item.qty = item.qty - 1;
                    });
                  }
                  widget.onUpdate?.call();
                }
              },
            ),
            const SizedBox(width: 8),
            _buildQuantityDisplay(),
            const SizedBox(width: 8),
            _buildQuantityButton(
              type:1,
              icon: Icons.add,
              onTap: () {
                if(!widget.edit) {
                  cartCubit.incrementQuantity(item.id,
                      type: barcodeScan ? CartType.barcode : CartType.main);
                }else{
                  setState(() {
                    item.qty = item.qty + 1;
                    widget.onUpdate?.call();
                  });
                }
              },
            ),
          ],
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
        return widget.edit?MyTextfield.textStyle_w600(item.qty.toString(), 18, Colors.black87)
        :BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final quantity = barcodeScan
                ? state.barcodeCartItems.firstWhere(
                  (e) => e.id == item.id,
              orElse: () => item,
            ).qty
                : state.cartItems.firstWhere(
                  (e) => e.id == item.id,
              orElse: () => item,
            ).qty;

            return MyTextfield.textStyle_w600(quantity.toString(), 18, Colors.black87);
          },
        );
      },
    );
  }

  void _showRemoveBottomSheet(BuildContext context, CartCubit cartCubit) {
    String initials = item.product.length >= 2 ? item.product.substring(0, 2).toUpperCase() : item.product.toUpperCase();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyTextfield.textStyle_w600("REMOVE PRODUCT FROM CART", 14, Colors.grey[600]!),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 15),

            // Product info row
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.myGradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kPrimary.withOpacity(0.1)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:  Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: MyTextfield.textStyle_w800(initials, 20, AppColors.kPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield.textStyle_w600(item.product, 16, Colors.black),
                      MyTextfield.textStyle_w200(item.composition, 12, Colors.grey[600]!, maxLines: 2),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!widget.edit) {
                        cartCubit.removeFromCart(item.id, type: barcodeScan ? CartType.barcode : CartType.main);
                      } else {
                        widget.onRemove?.call();
                        widget.onUpdate?.call();// Let parent remove item from list
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImages.delete,
                          height: 18,
                          width: 18,
                          color: AppColors.kWhiteColor,
                        ),
                        SizedBox(width: 5),
                        Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
