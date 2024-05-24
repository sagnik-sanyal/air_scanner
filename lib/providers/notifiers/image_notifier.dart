import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/image_utils.dart';

part 'image_state.dart';

/// Notifier for the image state.
final imageNotiiferProvider =
    AutoDisposeNotifierProvider<ImageNotifier, ImageState>(
  ImageNotifier.new,
  name: 'imageNotiiferProvider',
);

/// Provider for the image state.
final class ImageNotifier extends AutoDisposeNotifier<ImageState> {
  late Dio _dio;
  static const String apiKey = 'API_KEY';
  static const String baseUrl = 'https://api.remove.bg/v1.0/removebg';

  @override
  ImageState build() {
    _dio = Dio();
    ImageUtils.instance.clearCache();
    return const ImageInitialState();
  }

  /// Set the image.
  void setPickedImage(XFile image) => state = ImageSelectedState(before: image);

  /// Clear the image.
  Future<void> clearImage() async {
    state = const ImageInitialState();
    await ImageUtils.instance.clearCache();
  }

  /// Upload Image and handle the response.
  Future<void> uploadImage(XFile image) async {
    final ImageState prevState = state;
    state = const ImageProcessingState(message: 'Validating image');
    final Response post = await _dio.post(
      baseUrl,
      options: Options(
        headers: {'X-API-Key': apiKey},
        responseType: ResponseType.bytes,
        contentType: 'multipart/form-data',
      ),
      data: FormData.fromMap(
        <String, MultipartFile>{
          'image_file': MultipartFile.fromBytes(await image.readAsBytes())
        },
      ),
      onSendProgress: _uploadProgress,
      onReceiveProgress: _downloadProgress,
    );

    if (post.statusCode == 200 && post.data != null) {
      // final String name = basenameWithoutExtension(image.path);
      // final String ext = extension(image.path);
      // final XFile? after = await ImageUtils.instance
      //     .createTempFile(post.data!, '$name-transparent', ext);
      state = ImageSelectedState(before: image, after: post.data!);
    } else {
      state = prevState;
    }
  }

  /// Set Upload Progress.
  void _uploadProgress(int count, int total) =>
      state = ImageProcessingState.uploading(count / total * 100);

  /// Set the download progress.
  void _downloadProgress(int count, int total) {
    final double percentage = count / total * 100;
    state = state.maybeWhen(
      processing: (double upload, _, __) => ImageProcessingState(
        uploadProgress: upload,
        downloadProgress: percentage,
        message: 'Processing image...',
      ),
      orElse: () => state,
    );
  }
}
