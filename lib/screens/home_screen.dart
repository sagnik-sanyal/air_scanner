import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../providers/notifiers/image_notifier.dart';
import '../providers/theme_provider.dart';
import '../utils/context_utils.dart';
import '../utils/image_utils.dart';
import 'image_viewer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> shareImage(XFile image, Uint8List list) async {
    final String x = extension(image.path);
    final String name = '${basenameWithoutExtension(image.path)}-transparent';
    final XFile? file = await ImageUtils.instance.saveFile(list, name, x);
    if (file == null) return;
    await ImageUtils.instance.shareImage(file);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<void>> googleFonts = ref.watch(googleFontsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIR SCANNER'),
        actions: <Consumer>[
          Consumer(
            child: IconButton(
              icon: const Icon(Icons.restore_rounded, color: Colors.white),
              onPressed: ref.read(imageNotiiferProvider.notifier).clearImage,
            ),
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final ImageState state = ref.watch(imageNotiiferProvider);
              return state.maybeWhen(
                selected: (_, __) => child!,
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: googleFonts.when(
          loading: () => const CircularProgressIndicator(),
          error: (Object error, _) => Text('Error: $error'),
          data: (_) => const ImageViewer(),
        ),
      ),
      bottomSheet: Consumer(
        child: _bottomSheet(context, ref),
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final ImageState state = ref.watch(imageNotiiferProvider);
          return state.maybeWhen(
            initial: () => child!,
            selected: (XFile before, Uint8List? after) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: <Expanded>[
                  if (after != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async => shareImage(before, after),
                        icon: const Icon(Icons.bluetooth_rounded),
                        label: const Text('Share Via Bluetooth'),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => ref
                            .read(imageNotiiferProvider.notifier)
                            .uploadImage(before),
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('Remove Background'),
                      ),
                    ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Container _bottomSheet(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('Choose an image to scan'),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final XFile? image = await ImageUtils.instance
                        .pickCameraImage(
                            onLimit: (String e) => context.showError(e));
                    if (image != null) {
                      ref
                          .read(imageNotiiferProvider.notifier)
                          .setPickedImage(image);
                    } else if (context.mounted) {
                      context.showError('No image was clicked');
                    }
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final XFile? image = await ImageUtils.instance
                        .pickGalleryImage(
                            onLimit: (String e) => context.showError(e));
                    if (image != null) {
                      ref
                          .read(imageNotiiferProvider.notifier)
                          .setPickedImage(image);
                    } else if (context.mounted) {
                      context.showError('No image was selected');
                    }
                  },
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
