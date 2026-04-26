import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Pick image from device (supports web and mobile)
  Future<PlatformFile?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb, // Get bytes for web
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi chọn ảnh: ${e.toString()}';
    }
  }

  // Pick multiple images from device (supports web and mobile)
  Future<List<PlatformFile>> pickMultipleImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb, // Get bytes for web
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files;
      }
      return [];
    } catch (e) {
      throw 'Lỗi khi chọn ảnh: ${e.toString()}';
    }
  }

  // Upload image to Firebase Storage (supports web and mobile)
  Future<String> uploadImage({
    required PlatformFile platformFile,
    required String folder,
    String? fileName,
  }) async {
    try {
      // Generate unique filename if not provided
      final String uniqueFileName = fileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${platformFile.name}';

      // Create reference to the file location
      final Reference ref = _storage.ref().child('$folder/$uniqueFileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        // For web: upload bytes
        if (platformFile.bytes == null) {
          throw 'Không thể đọc dữ liệu ảnh';
        }
        uploadTask = ref.putData(
          platformFile.bytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // For mobile/desktop: upload file
        if (platformFile.path == null) {
          throw 'Không tìm thấy đường dẫn file';
        }
        final File file = File(platformFile.path!);
        uploadTask = ref.putFile(file);
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Lỗi khi tải ảnh lên: ${e.toString()}';
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(imageUrl);
      final String path = uri.pathSegments.last;

      // Create reference and delete
      final Reference ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      // Log error but don't throw - image might already be deleted
      print('Lỗi khi xóa ảnh: ${e.toString()}');
    }
  }

  // Upload category image
  Future<String> uploadCategoryImage(PlatformFile platformFile, {String? categoryId}) async {
    return uploadImage(
      platformFile: platformFile,
      folder: 'categories',
      fileName: categoryId != null ? 'category_$categoryId.jpg' : null,
    );
  }

  // Delete category image
  Future<void> deleteCategoryImage(String imageUrl) async {
    await deleteImage(imageUrl);
  }
}
