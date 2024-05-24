import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/notifiers/image_notifier.dart';
import 'processing_animation.dart';

class ImageViewer extends ConsumerWidget {
  const ImageViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ImageState state = ref.watch(imageNotiiferProvider);
    return switch (state) {
      ImageInitialState() => const Text('No image selected'),
      ImageSelectedState(:final XFile before, :final Uint8List? after) => Stack(
          children: <Widget>[
            if (after != null) _verifiedIcon(),
            Positioned.fill(
              child: after != null ? _memoryImage(after) : _fileImage(before),
            ),
          ],
        ),
      final ImageProcessingState process => ProcessingAnimation(
          state: process,
          key: const ValueKey<String>('processing_animation'),
        ),
    };
  }

  Positioned _verifiedIcon() {
    return Positioned(
      top: 10,
      right: 10,
      child: OutlinedButton.icon(
        icon: const Icon(
          Icons.verified_rounded,
          color: Colors.green,
          size: 30,
        ),
        label: const Text('Uploaded'),
        onPressed: null,
      ),
    );
  }

  Image _fileImage(XFile before, [double dimension = double.infinity]) {
    return Image.file(File(before.path), height: dimension, width: dimension);
  }

  Image _memoryImage(Uint8List after, [double dimension = double.infinity]) {
    return Image.memory(after, height: dimension, width: dimension);
  }
}
