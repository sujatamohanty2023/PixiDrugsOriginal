import '../../constant/all.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:image_cropper/image_cropper.dart';

void AddPurchaseBottomSheet(
    BuildContext rootContext,
    Function(List<File>) onFileSelected, {
      int pick_Size = 5,
      bool pdf = false,
      bool ManualAdd = false,
    }) {
  List<File> _fileList = [];
  /*final picker = ImagePicker();

  // Function to handle image selection from gallery or camera
  Future<void> _selectImages({bool fromCamera = false}) async {
    try {
      List<XFile> pickedFiles = [];
      
      if (fromCamera) {
        // Single image from camera
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image != null) {
          pickedFiles = [image];
        }
      } else {
        // Multiple images from gallery (default)
        pickedFiles = await picker.pickMultiImage(imageQuality: 90);
      }
      
      if (pickedFiles.isEmpty) return;

      if (_fileList.length + pickedFiles.length > pick_Size) {
        AppUtils.showSnackBar(
            rootContext, 'You can only select up to $pick_Size images.');
      } else {
        List<File> files = pickedFiles.map((xfile) => File(xfile.path)).toList();
        _fileList = await cropImages(files);
        Navigator.pop(rootContext);
        onFileSelected(_fileList);
      }
    } catch (e) {
      AppUtils.showSnackBar(rootContext, 'Failed to pick images: $e');
    }
  }*/
  String _normalizeUri(String rawUri) {
    if (rawUri.startsWith('file://')) {
      return rawUri.replaceFirst('file://', '');
    }
    return rawUri;
  }
  Future<void> _scanLibraryCall(BuildContext context) async {
    _fileList.clear();
    dynamic scannedDocuments;

    try {
      scannedDocuments = await FlutterDocScanner().getScannedDocumentAsImages(page: pick_Size);
      print("🔍 Raw scannedDocuments = $scannedDocuments");
    } on PlatformException {
      AppUtils.showSnackBar(context, "Failed to get scanned documents.");
      return;
    }

    if (scannedDocuments == null ||
        scannedDocuments is! Map ||
        !scannedDocuments.containsKey("Uri")) {
      AppUtils.showSnackBar(context, "No document scanned.");
      return;
    }

    final pagesString = scannedDocuments["Uri"] as String;
    print("🧾 pagesString: $pagesString");

    final List<File> scannedFiles = [];

    final regex = RegExp(r'imageUri=([^}\s]+)');
    final matches = regex.allMatches(pagesString);

    for (final match in matches) {
      final uri = match.group(1);
      if (uri != null) {
        print("🔗 Extracted URI from string: $uri");
        scannedFiles.add(File(_normalizeUri(uri)));
      }
    }

    if (scannedFiles.isEmpty) {
      AppUtils.showSnackBar(context, "Could not extract any image paths.");
      return;
    }

    print("🔍 Number of scanned files: ${scannedFiles.length}");
    _fileList.addAll(scannedFiles);

    Navigator.pop(context); // Close scanner UI
    onFileSelected(_fileList); // Notify caller
  }

  showModalBottomSheet(
    context: rootContext,
    isScrollControlled: true,
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
          child: SingleChildScrollView(
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
                      Navigator.pop(rootContext);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        AppRoutes.navigateTo(
                            rootContext, AddPurchaseBill(manualAdd: true));
                      });
                    },
                  ),
                if (ManualAdd) _divider(),

                // Gallery option moved to top (default)
                _buildOption(
                  context,
                  icon: Icons.photo_library,
                  iconColor: Colors.blue,
                  title: "Choose from Gallery",
                  subtitle: "Select multiple images from gallery",
                  onTap: () => _scanLibraryCall(context),
                ),
                _divider(),

                _buildOption(
                  context,
                  icon: Icons.camera_alt,
                  iconColor: Colors.orange,
                  title: "Take Photo",
                  subtitle: "Capture using your camera",
                  onTap: () => _scanLibraryCall(context),
                ),
                _divider(),

                // Document Scanner option
               /* _buildOption(
                  context,
                  icon: Icons.document_scanner,
                  iconColor: Colors.green,
                  title: "Scan Document",
                  subtitle: "Use document scanner with auto-crop",
                  onTap: () =>_scanLibraryCall(context),
                ),
                _divider(),*/

                if (pdf)
                  _buildOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    iconColor: Colors.redAccent,
                    title: "Upload PDF file",
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
                SizedBox(height: 30,)
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
          hideBottomControls: false, // ✅ show controls
          showCropGrid: true,        // ✅ keep grid visible
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          cropFrameStrokeWidth: 2,    // ✅ makes crop frame clearer
          cropGridStrokeWidth: 1,
          cropGridColor: Colors.white.withOpacity(0.5),
          statusBarColor: Colors.black,
          backgroundColor: Colors.black.withOpacity(0.8), // ✅ adds dim background instead of full white
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
