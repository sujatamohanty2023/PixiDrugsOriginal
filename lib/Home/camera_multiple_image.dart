import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant/color.dart';
import '../customWidget/MyTextField.dart';
import '../invoiceDataExtraction/AddPurcheseBill.dart';

List<CameraDescription> cameras = [];

class MultiShotCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MultiShotCameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<MultiShotCameraScreen> createState() => _MultiShotCameraScreenState();
}

class _MultiShotCameraScreenState extends State<MultiShotCameraScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  List<XFile> _clickedImages = [];
  final ImagePicker _picker = ImagePicker();
  int? _replaceIndex;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isInitialized) return;

    // ✅ Check max limit
    if (_clickedImages.length >= 5 && _replaceIndex == null) {
      _showLimitMessage("Maximum 5 images allowed");
      return;
    }

    if (_replaceIndex != null) {
      final image = await _cameraController.takePicture();
      setState(() {
        _clickedImages[_replaceIndex!] = image;
        _replaceIndex = null;
      });
    } else {
      final image = await _cameraController.takePicture();
      setState(() => _clickedImages.add(image));
    }

    HapticFeedback.lightImpact();
  }


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
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<XFile> limitedSelection = pickedFiles.take(remainingSlots).toList();
      setState(() => _clickedImages.addAll(limitedSelection));

      if (pickedFiles.length > remainingSlots) {
        _showLimitMessage("Only $remainingSlots more images allowed");
      }
    }
  }


  Future<void> _toggleFlash() async {
    if (_isFlashOn) {
      await _cameraController.setFlashMode(FlashMode.off);
    } else {
      await _cameraController.setFlashMode(FlashMode.torch);
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
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    double headerHeight = screenH * 0.07;
    double thumbSize = screenH * 0.1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: headerHeight,
              padding: EdgeInsets.symmetric(horizontal: screenW * 0.04),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Take Your Photos",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.kPrimary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.kPrimaryDark, width: 1),
                    ),
                    child: TextButton(
                      onPressed: () {
                        List<String> _fileList=[];
                        for(var item in _clickedImages){
                          _fileList.add(item.path);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPurchaseBill(paths: _fileList),
                          ),
                        );
                      },
                      child: MyTextfield.textStyle_w800('Next', 18, AppColors.kWhiteColor),
                    ),
                  )
                ],
              ),
            ),

            // Camera Preview
            Expanded(
              child: _isCameraInitialized
                  ? LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: CameraPreview(_cameraController),
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
                  // Inside your buttons row:
                  GestureDetector(
                    onTap: _takePicture,
                    child: SvgPicture.asset(
                      'assets/circle.svg', // Your SVG file path
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