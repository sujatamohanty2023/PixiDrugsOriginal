// s3_upload_service.dart

import '../../constant/all.dart';

class S3UploadService {
  Dio dio = Dio();

  // Function to upload multiple images to AWS S3 with total progress tracking
  Future<List<String>> uploadImagesToS3({
    required List<String> images,
    required String bucketUrl,
    required Function(double totalProgress) onProgress, // Track total progress
  }) async {
    int completed = 0; // To count completed uploads
    int total = images.length; // Total number of images
    List<String> uploadedFileUrls = [];

    for (int i = 0; i < images.length; i++) {
      if (images[i].contains("https://medirobo.s3.amazonaws.com/")) {
        uploadedFileUrls.add(images[i]);
      } else {
        File imageFile = File(images[i]);
        String fileName =
            'pixidrugs_profile_pic/${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';

        try {
          await uploadFileToS3(
            file: imageFile,
            fileName: fileName,
            bucketUrl: bucketUrl,
            onProgress: (progress) {
              // Update the progress for the current image and update total progress
              double totalImageProgress =
                  (i + progress) / total; // Total progress
              onProgress(totalImageProgress); // Update total progress in the UI
            },
          );
          uploadedFileUrls
              .add("$bucketUrl/$fileName"); // Add the URL of the uploaded file
          print("uploadedFileUrls $bucketUrl/$fileName");

          completed++; // Increment completed uploads
        } catch (e) {
          print("Error uploading file ${imageFile.path}: $e");
          // Optionally, add more specific error handling for the current file
        }
      }
    }

    // Optionally, StockReturn the list of uploaded URLs if needed
    return uploadedFileUrls; // Return the list of uploaded file URLs
  }

  // Function to upload a single file to S3
  Future<void> uploadFileToS3({
    required File file,
    required String fileName,
    required String bucketUrl,
    required Function(double) onProgress,
  }) async {
    try {
      final mimeType =
          lookupMimeType(file.absolute.path) ?? 'application/octet-stream';
      print("mimeType : $mimeType");

      Response response = await dio.put(
        "$bucketUrl/$fileName",
        data: await file.readAsBytes(),
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'x-amz-acl': 'public-read',
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            double progress = sent / total; // Progress for the current image
            onProgress(progress); // Update progress for this image
          }
        },
      );

      if (response.statusCode == 200) {
        print("Upload success: ${response.data}");
      } else {
        print("Error: ${response.data}");
        throw Exception("Failed to upload file");
      }
    } catch (e) {
      print("Error while uploading file: $e");
      throw e; // Propagate the error for further handling
    }
  }
}
