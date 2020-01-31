import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../lottie.dart';
import 'lottie.dart';
import 'lottie_drawable.dart';
import 'providers/asset_provider.dart';
import 'providers/file_provider.dart';
import 'providers/lottie_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/network_provider.dart';

typedef LottieFrameBuilder = Widget Function(
  BuildContext context,
  Widget child,
  LottieComposition composition,
);

/// A widget that displays a Lottie animation.
///
/// Several constructors are provided for the various ways that a Lottie file
/// can be provided:
///
///  * [new Lottie], for obtaining an image from a [LottieProvider].
///  * [new Lottie.asset], for obtaining a Lottie file from an [AssetBundle]
///    using a key.
///  * [new Image.network], for obtaining a lottie file from a URL.
///  * [new Image.file], for obtaining a lottie file from a [File].
///  * [new Image.memory], for obtaining a lottie file from a [Uint8List].
///
class LottieBuilder extends StatefulWidget {
  const LottieBuilder({
    Key key,
    @required this.lottie,
    this.controller,
    this.onLoaded,
    this.frameBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment,
  })  : assert(lottie != null),
        super(key: key);

  /// Creates a widget that displays an [LottieStream] obtained from the network.
  LottieBuilder.network(
    String src, {
    this.controller,
    this.onLoaded,
    Key key,
    this.frameBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment,
  })  : lottie = NetworkLottie(src),
        super(key: key);

  /// Creates a widget that displays an [ImageStream] obtained from a [File].
  ///
  /// The [file], [scale], and [repeat] arguments must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// On Android, this may require the
  /// `android.permission.READ_EXTERNAL_STORAGE` permission.
  ///
  LottieBuilder.file(
    File file, {
    this.controller,
    this.onLoaded,
    Key key,
    this.frameBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment,
  })  : lottie = FileLottie(file),
        super(key: key);

  LottieBuilder.asset(
    String name, {
    this.controller,
    this.onLoaded,
    Key key,
    AssetBundle bundle,
    this.frameBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment,
    String package,
  })  : lottie = AssetLottie(name, bundle: bundle, package: package),
        super(key: key);

  /// Creates a widget that displays an [LottieDrawable] obtained from a [Uint8List].
  LottieBuilder.memory(
    Uint8List bytes, {
    this.controller,
    this.onLoaded,
    Key key,
    this.frameBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment,
  })  : lottie = MemoryLottie(bytes),
        super(key: key);

  /// The lottie animation to display.
  final LottieProvider lottie;

  /// A callback called when the LottieComposition has been loaded.
  /// You can use this callback to set the correct duration on the AnimationController
  /// with `composition.duration`
  final void Function(LottieComposition) onLoaded;

  /// The animation controller of the Lottie animation.
  /// The animated value will be mapped to the `progress` property of the
  /// Lottie animation.
  final AnimationController controller;

  /// A builder function responsible for creating the widget that represents
  /// this lottie animation.
  ///
  /// If this is null, this widget will display a lottie animation that is painted as
  /// soon as it is available (and will appear to "pop" in
  /// if it becomes available asynchronously). Callers might use this builder to
  /// add effects to the image (such as fading the image in when it becomes
  /// available) or to display a placeholder widget while the image is loading.
  ///
  /// To have finer-grained control over the way that an image's loading
  /// progress is communicated to the user, see [loadingBuilder].
  ///
  /// {@template lottie.chainedBuildersExample}
  /// ```dart
  /// Lottie(
  ///   ...
  ///   frameBuilder: (BuildContext context, Widget child) {
  ///     return Padding(
  ///       padding: EdgeInsets.all(8.0),
  ///       child: child,
  ///     );
  ///   }
  /// )
  /// ```
  ///
  /// In this example, the widget hierarchy will contain the following:
  ///
  /// ```dart
  /// Center(
  ///   Padding(
  ///     padding: EdgeInsets.all(8.0),
  ///     child: <lottie>,
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  ///
  /// {@tool snippet --template=stateless_widget_material}
  ///
  /// The following sample demonstrates how to use this builder to implement an
  /// image that fades in once it's been loaded.
  ///
  /// This sample contains a limited subset of the functionality that the
  /// [FadeInImage] widget provides out of the box.
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return DecoratedBox(
  ///     decoration: BoxDecoration(
  ///       color: Colors.white,
  ///       border: Border.all(),
  ///       borderRadius: BorderRadius.circular(20),
  ///     ),
  ///     child: Lottie.network(
  ///       'https://example.com/animation.json',
  ///       frameBuilder: (BuildContext context, Widget child) {
  ///         if (wasSynchronouslyLoaded) {
  ///           return child;
  ///         }
  ///         return AnimatedOpacity(
  ///           child: child,
  ///           opacity: frame == null ? 0 : 1,
  ///           duration: const Duration(seconds: 1),
  ///           curve: Curves.easeOut,
  ///         );
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  final LottieFrameBuilder frameBuilder;

  /// If non-null, require the lottie animation to have this width.
  ///
  /// If null, the lottie animation will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double width;

  /// If non-null, require the lottie animation to have this height.
  ///
  /// If null, the lottie animation will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double height;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  @override
  _LottieBuilderState createState() => _LottieBuilderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LottieProvider>('lottie', lottie));
    properties.add(DiagnosticsProperty<Function>('frameBuilder', frameBuilder));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(EnumProperty<BoxFit>('fit', fit, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
        'alignment', alignment,
        defaultValue: null));
  }
}

class _LottieBuilderState extends State<LottieBuilder> {
  Future<LottieComposition> _loadingFuture;
  bool _calledLoadedCallback = false;

  @override
  void initState() {
    super.initState();

    _loadingFuture = widget.lottie.load();
  }

  @override
  void didUpdateWidget(LottieBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.lottie != widget.lottie) {
      _loadingFuture = widget.lottie.load();
      _calledLoadedCallback = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        var composition = snapshot.data;
        if (composition != null && !_calledLoadedCallback) {
          _calledLoadedCallback = true;
          if (widget.onLoaded != null) {
            widget.onLoaded(composition);
          }
        }

        Widget result = Lottie(
          composition: composition,
          controller: widget.controller,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
        );

        if (widget.frameBuilder != null) {
          result = widget.frameBuilder(context, result, composition);
        }

        return result;
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<Future<LottieComposition>>(
        'loadingFuture', _loadingFuture));
  }
}