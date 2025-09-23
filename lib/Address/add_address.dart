import 'package:latlong2/latlong.dart';

import '../constant/all.dart';

class AddAddressScreen extends StatefulWidget {
  final String? address;
  final String? pinCode;
  final String? city;
  final String? state;
  final LatLng? currentLatLng;
  Function(String address,LatLng currentLatLng) onConfirm;

  AddAddressScreen(
      {Key? key,
      this.address,
      this.pinCode,
      this.currentLatLng,
      this.city,
      this.state, required this.onConfirm,})
      : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      addressController.text = widget.address!;
    }
    if (widget.pinCode != null) {
      pinCodeController.text = widget.pinCode!;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.kPrimaryLight,
          title: MyTextfield.textStyle_w600("Add Address", 25, Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: AppColors.myGradient),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextfield.textStyle_w600(
                                'Pin Code*', 18, Colors.black),
                            SizedBox(
                              height: 8,
                            ),
                            MyEdittextfield(
                              hintText: 'Pin Code',
                              controller: pinCodeController,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                  ),

                  MyTextfield.textStyle_w600('Address*', 18, Colors.black),
                  SizedBox(
                    height: 8,
                  ),
                  MyEdittextfield(
                    hintText: 'Apartment / house number, Street, area',
                    controller: addressController,
                  ),

                  SizedBox(height: 10),
                  MyTextfield.textStyle_w600('Landmark*', 18, Colors.black),
                  SizedBox(
                    height: 8,
                  ),
                  MyEdittextfield(
                    hintText: 'Enter a nearby landmark',
                    controller: landmarkController,
                  ),

                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 50,
          width: double.infinity,
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: MyElevatedButton(
            buttonText: "Save address",
            onPressed: () {
              var address=addressController.text+'\n'+
                  landmarkController.text+'\n'+
                  widget.city!+'\n'+
                  widget.state!+'\n'+
                  pinCodeController.text+'\n';
              widget.onConfirm(address,widget.currentLatLng!);
            },
          ),
        ));
  }
}
