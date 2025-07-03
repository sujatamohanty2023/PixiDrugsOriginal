import 'package:pixidrugs/constant/all.dart'; // Import your constants

void showImageBottomSheet(
    BuildContext context, Function(List<File>) onFileSelected,
    {int pick_Size = 3, bool pdf = false}) {
  final picker = ImagePicker();
  List<File> _fileList = [];

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Take a Photo Option
            ListTile(
              leading:
                  Icon(Icons.camera_alt_outlined, color: AppColors.kPrimary),
              title: Text('Take a Photo'),
              onTap: () async {
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _fileList.add(File(pickedFile.path));
                  onFileSelected(_fileList);
                }
                Navigator.pop(context);
              },
            ),

            // Choose from Gallery Option
            ListTile(
              leading: Icon(Icons.photo, color: AppColors.kPrimary),
              title: Text('Choose from Gallery'),
              onTap: () async {
                try {
                  final pickedFiles = await picker.pickMultiImage();
                  if (pickedFiles.isEmpty) {
                    // User canceled or no images selected
                    return;
                  }

                  if (_fileList.length + pickedFiles.length > pick_Size) {
                    // Show an alert if the total exceeds the pickSize limit
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'You can only select up to $pick_Size images.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    List<File> files =
                        pickedFiles.map((xfile) => File(xfile.path)).toList();
                    _fileList.addAll(files);
                    onFileSelected(_fileList);
                  }
                } catch (e) {
                  // Handle any potential errors with image picking
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to pick images: $e'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
                Navigator.pop(context);
              },
            ),

            // Pick PDF Option
            if (pdf)
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: AppColors.kPrimary),
                title: Text('Pick PDF'),
                onTap: () async {
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                            type: FileType.custom, allowedExtensions: ['pdf']);
                    if (result != null) {
                      File pdfFile = File(result.files.single.path!);
                      _fileList.add(pdfFile);
                      onFileSelected(_fileList);
                    }
                  } catch (e) {
                    // Handle any potential errors with PDF picking
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to pick PDF: $e'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      );
    },
  );
}
