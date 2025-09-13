import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/search/customerModel.dart';

import '../search/sellerModel.dart';

enum ProductCardMode { search, cart }

class ProductCard extends StatefulWidget {
  InvoiceItem item;
  ProductCardMode mode;
  bool editable;
  bool saleCart;
  VoidCallback? onRemove;
  VoidCallback? onUpdate;
  bool? returnStock;
  CartTypeSelection? cartTypeSelection;

  ProductCard({
    super.key,
    required this.item,
    this.mode = ProductCardMode.search,
    this.editable = false,
    this.saleCart = false,
    this.onRemove,
    this.onUpdate,
    this.returnStock = false,
    this.cartTypeSelection,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late TextEditingController discController;
  UnitType? selectedUnitType;
  double? disPlayMrp=0.0;
  @override
  void initState() {
    super.initState();
    discController = TextEditingController(text: widget.item.discountSale);
    selectedUnitType = widget.mode == ProductCardMode.cart?widget.item.unitType:AppUtils().detectUnitType(widget.item.packing);
  }

  @override
  void dispose() {
    discController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final isCartMode = widget.mode == ProductCardMode.cart;
    final isEditable = widget.editable;
    final unitType = !widget.saleCart ? widget.item.unitType : AppUtils()
        .detectUnitType(widget.item.packing);
    int packingQuantity = AppUtils().extractPackingQuantity(
        widget.item.packing);

    double mrp = double.tryParse(widget.item.mrp) ?? 0.0;
    disPlayMrp = mrp;
    if (selectedUnitType == UnitType.Tablet && packingQuantity > 0) {
      disPlayMrp = mrp / packingQuantity;
    } else if (selectedUnitType == UnitType.Tablet && isCartMode) {
      disPlayMrp = double.tryParse(widget.item.unitMrp);
    }

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.kPrimaryDark, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  if (widget.editable && isCartMode && widget.saleCart)
                    _buildRemoveIcon(context, cartCubit),

                  if ((unitType != null && (unitType == UnitType.Tablet ||
                      unitType == UnitType.Strip) && isCartMode) ||
                      (unitType != null && (unitType == UnitType.Tablet ||
                          unitType == UnitType.Strip) && widget.saleCart)) ...[
                    Positioned(
                      top: 30,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondaryColor,
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        child: PopupMenuButton<UnitType>(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: AppColors.kWhiteColor,
                          elevation: 8,
                          onSelected: widget.editable
                              ? (val) {
                            setState(() {
                              selectedUnitType = val;
                              widget.item.unitType = val;

                              final fullMrp = double.tryParse(
                                  widget.item.mrp) ?? 0.0;
                              final packingQuantity = AppUtils()
                                  .extractPackingQuantity(widget.item.packing);

                              double? unitMrp;
                              if (val == UnitType.Tablet &&
                                  packingQuantity > 0) {
                                unitMrp = fullMrp / packingQuantity;
                                widget.item.unitMrp =
                                    unitMrp.toStringAsFixed(2);
                              } else {
                                widget.item.unitMrp =
                                    fullMrp.toStringAsFixed(2);
                              }
                            });

                            cartCubit.updateItemUnitRate(
                              widget.item.id!,
                              double.tryParse(widget.item.unitMrp ?? '0') ??
                                  0.0,
                              type: CartType.main,
                              unitType: selectedUnitType!,
                            );

                            widget.onUpdate?.call();
                          }
                              : null,
                          itemBuilder: (context) =>
                              UnitType.values
                                  .map((unit) =>
                                  PopupMenuItem<UnitType>(
                                    value: unit,
                                    child: Text(
                                      unit.name,
                                      style: MyTextfield.textStyle(
                                          14, AppColors.secondaryColor,
                                          FontWeight.w600),
                                    ),
                                  ))
                                  .toList(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedUnitType?.name ?? 'Select Unit',
                                style: MyTextfield.textStyle(
                                    14, AppColors.secondaryColor,
                                    FontWeight.w600),
                              ),
                              Icon(Icons.arrow_drop_down_sharp,
                                  color: AppColors.secondaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                  Row(
                    children: [
                      _buildProductImage(),
                      const SizedBox(width: 10),
                      Expanded(child: _buildProductDetails(
                          context, cartCubit, isCartMode, isEditable)),
                    ],
                  ),
                  _buildQuantityControls(context, cartCubit,isCartMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    String initials = widget.item.product.length >= 2
        ? widget.item.product.substring(0, 2).toUpperCase()
        : widget.item.product.toUpperCase();
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient1,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.secondaryColor, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.screenWidth! * 0.04),
        child: MyTextfield.textStyle_w800(initials, SizeConfig.screenWidth! * 0.05, AppColors.loginbg),
      ),
    );
  }
  Widget _buildProductDetails(BuildContext context, CartCubit cartCubit, bool isCartMode, bool isEditable) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.returnStock==true)
          widget.cartTypeSelection==CartTypeSelection.StockiestReturn?
          MyTextfield.textStyle_w400('${widget.item.sellerName} / ${widget.item.sellerPhone}', 18, Colors.red):
          MyTextfield.textStyle_w400('${widget.item.customerName} / ${widget.item.customerPhone}', 18, Colors.red),

        MyTextfield.textStyle_w600(widget.item.product, 18, AppColors.kPrimary),
        MyTextfield.textStyle_w200('Batch No.${widget.item.batch}', 12, AppColors.kPrimary),
        MyTextfield.textStyle_w200(widget.item.composition??'No Composition', 12, Colors.grey[600]!),
        const SizedBox(height: 4),
        MyTextfield.textStyle_w600("${AppString.Rupees}${disPlayMrp?.toStringAsFixed(2)}", 16, Colors.green),
        if (isCartMode) const SizedBox(height: 4),
        if (isCartMode)
          Row(
            children: [
              SizedBox(
                height: 30,
                width: 60,
                child: MyEdittextfield(
                  controller: discController,
                  hintText: "Discount",
                  keyboardType: TextInputType.number,
                  readOnly: !widget.editable,
                  onChanged: (val) {
                    final discountSale = double.tryParse(val) ?? 0.0;
                    widget.item.discountSale = discountSale.toString();
                    if (widget.saleCart==false && isEditable) {
                      widget.onUpdate?.call();
                    } else {
                      cartCubit.updateItemDiscount(
                        widget.item.id!,
                        discountSale,
                        type: CartType.main,
                        discountType: widget.item.discountType,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              MyTextfield.textStyle_w600("% Off", 14, AppColors.kPrimary),
            ],
          ),
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context,CartCubit cartCubit, bool isCartMode) {
    final isSearchMode = widget.mode == ProductCardMode.search;

    return Positioned(
      bottom: 5,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            InvoiceItem? cartItem;
            try {
              cartItem = state.cartItems.firstWhere((e) => e.id == widget.item.id);
            } catch (e) {
              cartItem = null;
            }

            final quantity = cartItem?.qty ?? 0;
            final bool isOutOfStock =  widget.cartTypeSelection != CartTypeSelection.CustomerReturn?widget.item.stock <= 0:false;

            if (isSearchMode && isOutOfStock){
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MyTextfield.textStyle_w600("Out of Stock", 14, Colors.white),
              );
            }

            print('Add Cart item=${cartCubit.state.cartItems.toString()}');
            if (isSearchMode && quantity==0 && !isOutOfStock ) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                  onPressed: () {
                    print('Add item=${widget.item.id}');
                    cartCubit.addToCart(widget.item, 1, type: CartType.main);

                    if (widget.returnStock == true) {
                      _navigateBackWithCustomer();
                    }
                  },
                child: MyTextfield.textStyle_w600("Add", 14, Colors.white),
              );
            } else if (quantity>=1 && !isOutOfStock) {
              return Row(
                children: [
                  _buildQuantityButton(
                    type: 0,
                    icon: Icons.remove,
                    onTap: () {
                      if (widget.saleCart==false && widget.editable) {
                        if (widget.item.qty <= 1) {
                          widget.onRemove?.call();
                        } else {
                          setState(() {
                            widget.item.qty--;
                          });
                        }
                        widget.onUpdate?.call();
                      } else {
                        if (quantity <= 1) {
                          cartCubit.removeFromCart(widget.item.id!,
                              type: CartType.main);
                        } else {
                          cartCubit.decrementQuantity(widget.item.id!,
                              type: CartType.main);
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuantityDisplay(),
                  const SizedBox(width: 8),
                  _buildQuantityButton(
                    type: 1,
                    icon: Icons.add,
                    onTap: () {
                      if (widget.saleCart==false && widget.editable) {
                        setState(() {
                          widget.item.qty++;
                        });
                        widget.onUpdate?.call();
                      } else {
                        cartCubit.incrementQuantity(widget.item.id!,
                            type: CartType.main);
                      }
                    },
                  ),
                ],
              );
            }else{
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
  void _navigateBackWithCustomer() {
    CustomerModel updatedCustomer;
    if (widget.cartTypeSelection == CartTypeSelection.StockiestReturn) {
      updatedCustomer = CustomerModel(
        id: widget.item.sellerId ?? 0,
        name: widget.item.sellerName ?? '',
        phone: widget.item.sellerPhone ?? '',
        address: '',
      );
    } else {
      updatedCustomer = CustomerModel(
        id: widget.item.customerId ?? 0,
        name: widget.item.customerName ?? '',
        phone: widget.item.customerPhone ?? '',
        address: '',
      );
    }

    var result = {
      'code': 'manualAdd',
      'selectedCustomer': updatedCustomer,
    };
    Navigator.pop(context, result);
  }

  Widget _buildQuantityDisplay() {
    return Builder(
      builder: (context) {
        return widget.mode==ProductCardMode.cart && !widget.saleCart?MyTextfield.textStyle_w600(widget.item.qty.toString(), 18, Colors.black87)
            :BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            InvoiceItem? cartItem;
            try {
              cartItem = state.cartItems.firstWhere((e) => e.id == widget.item.id);
            } catch (e) {
              cartItem = null;
            }
            final quantity = cartItem?.qty??'0';
            return MyTextfield.textStyle_w600(quantity.toString(), 18, Colors.black87);
          },
        );
      },
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
          borderRadius: type == 0
              ? const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
              : const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
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

  void _showRemoveBottomSheet(BuildContext context, CartCubit cartCubit) {
    String initials = widget.item.product.length >= 2 ? widget.item.product.substring(0, 2).toUpperCase() : widget.item.product.toUpperCase();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyTextfield.textStyle_w600("REMOVE PRODUCT FROM CART", 14, Colors.grey[600]!),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 15),
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
                    padding: const EdgeInsets.all(18.0),
                    child: MyTextfield.textStyle_w800(initials, 20, AppColors.kPrimary),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield.textStyle_w600(widget.item.product, 16, Colors.black),
                      MyTextfield.textStyle_w200(widget.item.composition??'', 12, Colors.grey[600]!, maxLines: 2),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.saleCart) {
                        cartCubit.removeFromCart(widget.item.id!,
                            type: CartType.main);
                      } else {
                        widget.onRemove?.call();
                        widget.onUpdate?.call();
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
                        SvgPicture.asset(AppImages.delete, height: 18, width: 18, color: AppColors.kWhiteColor),
                        const SizedBox(width: 5),
                        const Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14)),
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