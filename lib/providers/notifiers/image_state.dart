part of 'image_notifier.dart';

sealed class ImageState extends Equatable {
  const ImageState();

  bool get isInitial => this is ImageInitialState;

  T when<T>({
    required T Function() initial,
    required T Function(XFile before, Uint8List? after) selected,
    required T Function(double upload, double download, String message)
        processing,
  }) =>
      switch (this) {
        ImageInitialState() => initial(),
        ImageSelectedState(:final before, :final after) =>
          selected(before, after),
        ImageProcessingState(
          :final uploadProgress,
          :final downloadProgress,
          :final message
        ) =>
          processing(uploadProgress, downloadProgress, message),
      };

  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? initial,
    T Function(XFile before, Uint8List? after)? selected,
    T Function(double upload, double download, String message)? processing,
  }) =>
      switch (this) {
        ImageInitialState() => initial?.call() ?? orElse(),
        ImageSelectedState(:final before, :final after) =>
          selected?.call(before, after) ?? orElse(),
        ImageProcessingState(
          :final uploadProgress,
          :final downloadProgress,
          :final message
        ) =>
          processing?.call(uploadProgress, downloadProgress, message) ??
              orElse(),
      };
}

final class ImageInitialState extends ImageState {
  const ImageInitialState();

  @override
  List<Object?> get props => [];
}

final class ImageSelectedState extends ImageState {
  final XFile before;
  final Uint8List? after;

  const ImageSelectedState({required this.before, this.after});

  @override
  List<Object?> get props => <Object?>[before, after];

  @override
  String toString() => 'ImageSelectedState { before: $before, after: $after }';
}

final class ImageProcessingState extends ImageState {
  final double uploadProgress;
  final double downloadProgress;
  final String message;

  const ImageProcessingState({
    this.uploadProgress = 0,
    this.downloadProgress = 0,
    this.message = 'Uploading image...',
  });

  factory ImageProcessingState.uploading(double val) =>
      ImageProcessingState(message: 'Uploading image...', uploadProgress: val);

  factory ImageProcessingState.downloading(double val) => ImageProcessingState(
      message: 'Processing image...', downloadProgress: val);

  double get progress => (uploadProgress + downloadProgress) / 2;

  @override
  List<Object?> get props => [uploadProgress, downloadProgress, message];
}
