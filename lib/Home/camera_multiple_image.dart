import '../../constant/all.dart';
// import 'package:camera/camera.dart'; // Temporarily disabled
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';

class MultiShotCameraScreen extends StatefulWidget {
  // final List<CameraDescription> cameras; // Temporarily disabled
  //const MultiShotCameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<MultiShotCameraScreen> createState() => _MultiShotCameraScreenState();
}

class _MultiShotCameraScreenState extends State<MultiShotCameraScreen> {
  // late CameraController _cameraController; // Temporarily disabled
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  final List<File> _clickedImages = [];
  final ImagePicker _picker = ImagePicker();
  int? _replaceIndex;

  @override
  void initState() {
    super.initState();
    // _initCamera(); // Temporarily disabled
    setState(() => _isCameraInitialized = true); // Placeholder
  }

  // Future<void> _initCamera() async {
  //   _cameraController = CameraController(
  //     widget.cameras.first,
  //     ResolutionPreset.high,
  //     enableAudio: false,
  //     imageFormatGroup: ImageFormatGroup.jpeg,
  //   );
  //   await _cameraController.initialize();
  //   if (!mounted) return;
  //   setState(() => _isCameraInitialized = true);
  // } // Temporarily disabled

  /*Future<void> _takePicture() async {
    // if (!_cameraController.value.isInitialized) return; // Temporarily disabled
    return; // Disabled functionality

    // ✅ Enforce max 5
    if (_clickedImages.length >= 5 && _replaceIndex == null) {
      _showLimitMessage("Maximum 5 images allowed");
      return;
    }

    try {
      final raw = await _cameraController.takePicture();

      final croppedFiles = await cropImages([XFile(raw.path)]); // This returns List<File>
      if (!mounted) return;

    // Check if user cropped the image or cancelled
      if (croppedFiles.isEmpty) return;

      final croppedFile = croppedFiles.first;

      setState(() {
        if (_replaceIndex != null) {
          _clickedImages[_replaceIndex!] = croppedFile;
          _replaceIndex = null;
        } else {
          _clickedImages.add(croppedFile);
        }
      });
      HapticFeedback.lightImpact();
    } catch (e) {
      _showLimitMessage("Failed to capture/crop");
    }
  }*/
  void _showLimitMessage(String message) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.45,
        left: MediaQuery.of(context).size.width * 0.2,
        right: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry?.remove();
    });
  }
  Future<void> _pickFromGallery() async {
    int remainingSlots = 5 - _clickedImages.length;
    if (remainingSlots <= 0) {
      _showLimitMessage("Maximum 5 images allowed");
      return;
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    // Limit to the remaining slots
    final limitedSelection = pickedFiles.take(remainingSlots).toList();

    final cropped = await cropImages(limitedSelection);
    setState(() {
      _clickedImages.addAll(cropped);
    });

    if (pickedFiles.length > remainingSlots) {
      _showLimitMessage("Only $remainingSlots more images allowed");
    }
  }

  Future<List<File>> cropImages(List<XFile> files) async {
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

  Future<void> _toggleFlash() async {
    if (_isFlashOn) {
      //await _cameraController.setFlashMode(FlashMode.off);
    } else {
      //await _cameraController.setFlashMode(FlashMode.torch);
    }
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _deleteImage(int index) {
    setState(() => _clickedImages.removeAt(index));
    HapticFeedback.mediumImpact();
  }

  void _showFullImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onImageTap(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text("View Image"),
                onTap: () {
                  Navigator.pop(context);
                  _showFullImage(_clickedImages[index].path);
                  HapticFeedback.selectionClick();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Retake with Camera"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _replaceIndex = index);
                  HapticFeedback.selectionClick();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteImage(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // _cameraController.dispose(); // Temporarily disabled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final headerHeight = screenH * 0.07;
    final thumbSize = screenH * 0.1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: headerHeight,
              color: Colors.black,
              child:  Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        SizedBox(width: 10),
                        MyTextfield.textStyle_w600(
                          'Take photo',
                          SizeConfig.screenWidth! * 0.055,
                          Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      child: MyElevatedButton(
                        onPressed: () => Navigator.pop(context,_clickedImages),
                        backgroundColor: AppColors.kPrimaryDark,
                        titleColor: AppColors.kPrimary,
                        custom_design: true,
                        buttonText: "Done",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Camera Preview
            Expanded(
              child: _isCameraInitialized
                  ? LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: Container(color: Colors.black, child: Center(child: Text('Camera Disabled', style: TextStyle(color: Colors.white)))), // CameraPreview disabled
                  );
                },
              )
                  : const Center(child: CircularProgressIndicator()),
            ),

            // Thumbnails
            if (_clickedImages.isNotEmpty)
              Container(
                height: thumbSize + 10,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _clickedImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onImageTap(index),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: screenW * 0.01),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(_clickedImages[index].path),
                            height: thumbSize,
                            width: thumbSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom Buttons
            Container(
              padding: EdgeInsets.all(screenW * 0.02),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    iconSize: screenW * 0.06,
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                  // Shutter
                  GestureDetector(
                    onTap:(){} /*_takePicture*/,
                    child: SvgPicture.asset(
                      AppImages.camera,
                      width: screenW * 0.16,
                      height: screenW * 0.16,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    iconSize: screenW * 0.06,
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.image, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}