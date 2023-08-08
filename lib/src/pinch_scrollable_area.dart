import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pinch_scrollable/src/pinch_image_data.dart';

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// a zone displaying image's zooming
class PinchScrollableArea extends StatefulWidget {
  const PinchScrollableArea({
    Key? key,
    required this.child,
    this.fadeColor,
    this.imageFit,
    this.httpHeaders,
    this.borderRadius,
    this.releaseDuration = defaultReleaseDuration,
  }) : super(key: key);

  static const int defaultReleaseDuration = 300;

  final Widget child;

  // fade effect base color
  final Color? fadeColor;

  // custom image border
  final BorderRadiusGeometry? borderRadius;

  // How to inscribe the image into the space allocated during layout.
  final BoxFit? imageFit;

  // release duration in milliseconds
  final int releaseDuration;

  // Optional headers for the http request of the image url
  final Map<String, String>? httpHeaders;

  @override
  PinchScrollableAreaState createState() => PinchScrollableAreaState();
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
class PinchScrollableAreaState extends State<PinchScrollableArea> {
  // a move animation's duration
  static const _animationDuration = Duration(milliseconds: 50);

  late Duration _releaseDuration;

  // zoom received from Listener
  double _zoom = 0;

  // calculated image size and position
  double? _imageLeft;
  double? _imageTop;
  double? _imageWidth;
  double? _imageHeight;

  // image url
  String? _imageUrl;

  // initial image data
  PinchImageData? _initialImageData;

  // have to show a release animation flag
  late bool _releaseAnimationEnabled;

  // stream receiving data from item containers
  StreamController<Object?>? _eventsStreamController;

  late StreamSubscription<Object?> _eventsSubscription;

  // stream to notify zoom start and end events
  late StreamController<bool> _zoomStreamController;

  Stream<bool> get zoomStream => _zoomStreamController.stream;

  StreamController<Object?>? get eventsStreamController =>
      _eventsStreamController;

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    _releaseDuration = Duration(milliseconds: widget.releaseDuration);

    _releaseAnimationEnabled = false;
    _eventsStreamController = StreamController<Object?>.broadcast();
    _eventsSubscription =
        _eventsStreamController!.stream.listen(_onZoomStreamEvent);

    _zoomStreamController = StreamController<bool>.broadcast();

    super.initState();
  }

  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _eventsSubscription.cancel();
    _eventsStreamController?.close();
    _zoomStreamController.close();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool initialized = imageInitialized();
    Widget imageContent = initialized
        ? CachedNetworkImage(
            imageUrl: _imageUrl!,
            fit: widget.imageFit ?? BoxFit.cover,
            height: _imageHeight,
            width: _imageWidth,
            httpHeaders: widget.httpHeaders,
          )
        : const SizedBox.shrink();

    if (widget.borderRadius != null) {
      imageContent = ClipRRect(
        borderRadius: widget.borderRadius,
        child: imageContent,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        //
        // fade effect
        Positioned.fill(
            child: IgnorePointer(
          child: AnimatedContainer(
            duration: _animationDuration,
            color: (widget.fadeColor ?? Colors.black)
                .withOpacity(max(0, min(0.7, ((_zoom - 1) / 5)))),
          ),
        )),
        //
        // if image details is initialized
        if (imageInitialized())
          // then display positioned zoomed image
          AnimatedPositioned(
              duration: _releaseAnimationEnabled
                  ? _releaseDuration
                  : _animationDuration,
              left: (_releaseAnimationEnabled && _initialImageData != null)
                  ? _initialImageData!.globalPosition.dx
                  : _imageLeft,
              top: (_releaseAnimationEnabled && _initialImageData != null)
                  ? _initialImageData!.globalPosition.dy
                  : _imageTop,
              child: IgnorePointer(
                  child: AnimatedScale(
                scale: _zoom,
                duration: _releaseAnimationEnabled
                    ? _releaseDuration
                    : _animationDuration,
                child: imageContent,
              ))),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // is image details initialized?
  bool imageInitialized() =>
      _imageLeft != null &&
      _imageTop != null &&
      _imageWidth != null &&
      _imageHeight != null &&
      _imageUrl != null;

  // ---------------------------------------------------------------------------
  // new event from pinch item container
  void _onZoomStreamEvent(Object? event) {
    // pinch initialization event
    if (event is PinchImageData && _initialImageData == null) {
      _releaseAnimationEnabled = false;
      setState(() {
        _initialImageData = event;
        _imageLeft = event.globalPosition.dx;
        _imageTop = event.globalPosition.dy;
        _imageWidth = event.paintBounds.width;
        _imageHeight = event.paintBounds.height;
        _imageUrl = event.imagePath;
        _zoom = 1;
      });
    }
    // start pinch event
    if (event is ScaleStartDetails && imageInitialized()) {
      _zoomStreamController.add(true);
    }
    // move fingers event
    if (event is ScaleUpdateDetails &&
        imageInitialized() &&
        !_releaseAnimationEnabled) {
      setState(() {
        // change zoom
        _zoom = event.scale;
        // move image
        _imageLeft = _imageLeft! + event.focalPointDelta.dx;
        _imageTop = _imageTop! + event.focalPointDelta.dy;
      });
    }
    // close pinch event
    if (event is ScaleEndDetails) {
      _zoomStreamController.add(false);
      setState(() {
        // start release animation
        _releaseAnimationEnabled = true;
        _zoom = 1;
      });
      // then clean last pinch details
      Future<void>.delayed(_releaseDuration).then((value) {
        if (_initialImageData != null) {
          setState(() {
            _initialImageData = null;
            _imageLeft = null;
            _imageTop = null;
            _imageWidth = null;
            _imageHeight = null;
            _imageUrl = null;
            _zoom = 1;
          });
        }
      });
    }
  }
}
