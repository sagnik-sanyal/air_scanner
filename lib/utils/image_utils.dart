import 'dart:developer';
import 'dart:io' show Directory, File, FileSystemException;

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:share_plus/share_plus.dart';

final class ImageUtils {
  const ImageUtils._();
  static ImageUtils? _instance;
  static ImageUtils get instance => _instance ??= const ImageUtils._();

  /// Pick an image from the gallery
  Future<XFile?> pickGalleryImage({
    int maxSizeMB = 10,
    void Function(String error)? onLimit,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      final int fileSize = (await image.readAsBytes()).length;
      if (fileSize > maxSizeMB * 1048576) {
        onLimit?.call('File size exceeded $maxSizeMB MB');
        return null;
      }
      return image;
    } on Exception {
      return null;
    }
  }

  /// Pick an image from the camera
  Future<XFile?> pickCameraImage({
    int maxSizeMB = 10,
    void Function(String error)? onLimit,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;
      final int fileSize = (await image.readAsBytes()).length;
      if (fileSize > maxSizeMB * 1048576) {
        onLimit?.call('File size exceeded $maxSizeMB MB');
        return null;
      }
      return image;
    } on Exception {
      return null;
    }
  }

  /// Retrieve lost image
  Future<XFile?> retrieveLostData() async {
    try {
      final ImagePicker picker = ImagePicker();
      final LostDataResponse response = await picker.retrieveLostData();
      if (response.isEmpty) return null;
      return response.file;
    } on Exception {
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final Directory dir = await getTemporaryDirectory();
      await dir.delete(recursive: true);
      log('Cache cleared');
    } on FileSystemException catch (e) {
      log('Failed to clear cache', error: e);
    }
  }

  /// Share image via any medium
  Future<ShareResult?> shareImage(XFile file) async {
    try {
      return await Share.shareXFiles(<XFile>[file]);
    } on Exception catch (e) {
      log('Failed to share image', error: e);
      return null;
    }
  }

  /// Create a file in temporary directory
  Future<XFile?> saveFile(Uint8List list, String name, String ext) async {
    try {
      final Directory dir = await getTemporaryDirectory();
      final DateTime now = DateTime.timestamp();
      final String fileName = '$name-$now.$ext';
      final File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(list);
      return XFile(
        file.path,
        name: fileName,
        lastModified: now,
        length: list.length,
      );
    } on FileSystemException catch (e) {
      log('Failed to create file from data', error: e);
      return null;
    }
  }
}
