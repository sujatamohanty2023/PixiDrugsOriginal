import 'package:PixiDrugs/constant/all.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import '../Home/camera_multiple_image.dart';

void AddPurchaseBottomSheet(
    BuildContext rootContext,
    Function(List<File>) onFileSelected, {
      int pick_Size = 5,
      bool pdf = false,
      bool ManualAdd = false,
    }) {
  final picker = ImagePicker();
  List<File> _fileList = [];

  showModalBottomSheet(
    context: rootContext,
    isScrollControlled: true, // Optional for full height
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // To prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (ManualAdd)
                  _buildOption(
                    context,
                    icon: Icons.edit_note,
                    iconColor: Colors.deepPurple,
                    title: "Add Invoice Manually",
                    subtitle: "Search to Add from 3 Lac+ Items",
                    onTap: () async {
                      Navigator.pop(rootContext);  // Changed here
                      Future.delayed(const Duration(milliseconds: 200), () {
                        AppRoutes.navigateTo(
                            rootContext, AddPurchaseBill(manualAdd: true));
                      });
                    },
                  ),
                if (ManualAdd) _divider(),

                _buildOption(
                  context,
                  icon: Icons.camera_alt,
                  iconColor: Colors.orange,
                  title: "Take Photo",
                  subtitle: "Capture using your camera",
                  onTap: () async {
                    List<CameraDescription> cameras = await availableCameras();
                    final result = await Navigator.push(
                      context,  // Changed here
                      MaterialPageRoute(
                        builder: (_) => MultiShotCameraScreen(cameras: cameras),
                      ),
                    );
                    if (result != null && result is List<File>) {
                      print("Captured images from camera: ${result.map((e) => e.path).toList()}");
                      _fileList.addAll(result);
                      Navigator.pop(rootContext);  // Close sheet first
                      onFileSelected(_fileList);
                    }
                  },
                ),
                _divider(),

                _buildOption(
                  context,
                  icon: Icons.photo_library,
                  iconColor: Colors.blue,
                  title: "Choose from Gallery",
                  subtitle: "Select an existing image",
                  onTap: () async {
                    try {
                      final pickedFiles = await picker.pickMultiImage();
                      if (pickedFiles.isEmpty) return;

                      if (_fileList.length + pickedFiles.length > pick_Size) {
                        AppUtils.showSnackBar(
                            context, 'You can only select up to $pick_Size images.');
                      } else {
                        List<File> files =
                        pickedFiles.map((xfile) => File(xfile.path)).toList();
                        _fileList = await cropImages(files);
                        Navigator.pop(context);
                        onFileSelected(_fileList);
                      }
                    } catch (e) {
                      AppUtils.showSnackBar(context, 'Failed to pick images: $e');
                    }
                  },
                ),
                _divider(),

                if (pdf)
                  _buildOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    iconColor: Colors.redAccent,
                    title: "Pick PDF",
                    subtitle: "Upload a single or multi-page PDF",
                    onTap: () async {
                      try {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom, allowedExtensions: ['pdf']);

                        if (result != null) {
                          File pdfFile = File(result.files.single.path!);
                          _fileList.add(pdfFile);

                          Navigator.pop(rootContext);
                          onFileSelected(_fileList);

                          // Then navigate to AddPurchaseBill page
                          Navigator.push(
                            rootContext,
                            MaterialPageRoute(
                              builder: (context) => AddPurchaseBill(paths: [pdfFile.path]),
                            ),
                          );
                        }
                      } catch (e) {
                        AppUtils.showSnackBar(context, 'Failed to pick PDF: $e');
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<List<File>> cropImages(List<File> files) async {
  List<File> croppedFileList = [];

  for (final file in files) {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.kPrimary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.kPrimary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      croppedFileList.add(File(croppedFile.path));
    }
  }
  return croppedFileList;
}

// Reusable widget for each option
Widget _buildOption(
    BuildContext context, {
      required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle,
      required Function() onTap,
    }) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextfield.textStyle_w600(
                    title, SizeConfig.screenWidth! * 0.054, AppColors.kPrimary),
                const SizedBox(height: 2),
                MyTextfield.textStyle_w300(
                    subtitle, SizeConfig.screenWidth! * 0.045, Colors.grey.shade600),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.loginbg),
        ],
      ),
    ),
  );
}

// Simple divider
Widget _divider() {
  return const Divider(
    height: 1,
    color: AppColors.kPrimaryDark,
  );
}
