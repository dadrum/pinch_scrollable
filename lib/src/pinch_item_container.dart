import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinch_scrollable/src/pinch_image_data.dart';
import 'pinch_scrollable_area.dart';

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// A container that accepts gestures and contains an image inside that needs to be enlarged
class PinchItemContainer extends StatefulWidget {
  const PinchItemContainer({
    Key? key,
    required this.child,
    required this.imageWidgetKey,
    required this.imageUrl,
  }) : super(key: key);

  // A widget that accepts pinch gestures
  final Widget child;

  // A key of the image. That image will zoom on pinch gesture
  final GlobalKey imageWidgetKey;

  // An image url, that displaying in child and will zoom
  final String imageUrl;

  @override
  State createState() => _PinchItemContainerState();
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
class _PinchItemContainerState extends State<PinchItemContainer> {
  late final Map<int, Offset> _fingers;

  // a zone controller of displaying image's zooming
  late StreamController<Object?> _pinchAreaStreamController;

  double? _startDistance;

  Offset? _lastFocalPoint;

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    _fingers = <int, Offset>{};

    super.initState();
  }

  // ---------------------------------------------------------------------------
  @override
  void didChangeDependencies() {
    // try to find pinch area
    final PinchScrollableAreaState? result =
        context.findAncestorStateOfType<PinchScrollableAreaState>();

    if (result?.eventsStreamController == null) {
      throw UnimplementedError(
          'PinchScrollableArea is not found or not initialized');
    }

    _pinchAreaStreamController = result!.eventsStreamController!;

    super.didChangeDependencies();
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        final int oldFingersCount = _fingers.length;
        _fingers[event.pointer] = event.position;
        if (oldFingersCount < 2 && _fingers.length >= 2) {
          _startDistance = _fingersDistance();
          _lastFocalPoint = _focalPoint();
          _onScaleStart(ScaleStartDetails());
        }
      },
      onPointerMove: (event) {
        _fingers[event.pointer] = event.position;
        if (_startDistance == null || _startDistance == 0) {
          _startDistance = _fingersDistance();
        } else {
          final Offset newFocalPoint = _focalPoint();
          final Offset prevFocalPoint = _lastFocalPoint ?? newFocalPoint;
          final Offset focalDelta = newFocalPoint - prevFocalPoint;
          _lastFocalPoint = newFocalPoint;

          _onScaleUpdate(ScaleUpdateDetails(
            scale: _fingersDistance() / _startDistance!,
            focalPointDelta: focalDelta,
          ));
        }
      },
      onPointerUp: (event) {
        final int oldFingersCount = _fingers.length;
        _fingers.remove(event.pointer);
        if (oldFingersCount >= 2 && _fingers.length < 2) {
          _startDistance = null;
          _onScaleEnd(ScaleEndDetails());
        }
      },
      child: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer(debugOwner: this),
            (TapGestureRecognizer instance) {
              instance.onTapDown = (_) {};
            },
          )
        },
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        child: widget.child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Offset _focalPoint() {
    if (_fingers.length < 2) return Offset.zero;

    final Iterable<Offset> firstFingers =
        _fingers.entries.map((e) => e.value).take(2);
    final Offset f1 = firstFingers.elementAt(0);
    final Offset f2 = firstFingers.elementAt(1);

    return Offset((f1.dx + f2.dx) * 0.5, (f1.dy + f2.dy) * 0.5);
  }

  // ---------------------------------------------------------------------------
  double _fingersDistance() {
    if (_fingers.length < 2) return 1;

    final Iterable<Offset> firstFingers =
        _fingers.entries.map((e) => e.value).take(2);
    final Offset f1 = firstFingers.elementAt(0);
    final Offset f2 = firstFingers.elementAt(1);

    return sqrt(
        (f1.dx - f2.dx) * (f1.dx - f2.dx) + (f1.dy - f2.dy) * (f1.dy - f2.dy));
  }

  // ---------------------------------------------------------------------------
  void _onScaleStart(ScaleStartDetails details) {
    if (!_pinchAreaStreamController.isClosed) {
      // determinate source data of image
      final RenderBox renderObject =
          widget.imageWidgetKey.currentContext?.findRenderObject() as RenderBox;

      final Offset position = renderObject.localToGlobal(Offset.zero);

      // add to stream an image initialization details
      _pinchAreaStreamController.add(PinchImageData(
        globalPosition: position,
        paintBounds: renderObject.paintBounds,
        imagePath: widget.imageUrl,
      ));

      // add a pinch start event to stream
      _pinchAreaStreamController.add(details);
    }
  }

  // ---------------------------------------------------------------------------
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_pinchAreaStreamController.isClosed) {
      // add a new pinch details event to stream
      _pinchAreaStreamController.add(details);
    }
  }

  // ---------------------------------------------------------------------------
  void _onScaleEnd(ScaleEndDetails details) {
    if (!_pinchAreaStreamController.isClosed) {
      // add a pinch end event to stream
      _pinchAreaStreamController.add(details);
    }
  }
}
