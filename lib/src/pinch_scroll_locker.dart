import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../pinch_scrollable.dart';

typedef ZoomStream = Stream<bool>;
typedef ZoomControllerSubscription = StreamSubscription<bool>;

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ignore: must_be_immutable
class PinchLockablePhysics extends ScrollPhysics {
  PinchLockablePhysics._(ScrollPhysics? physics, BuildContext? context)
      : super(parent: physics) {
    final PinchScrollableAreaState? scrollableAreaState =
        context?.findAncestorStateOfType<PinchScrollableAreaState>();

    ZoomStream? zoomStream = scrollableAreaState?.zoomStream;

    if (zoomStream == null) {
      throw UnimplementedError('PinchScrollableArea is not initialized');
    }

    _zoomControllerSubscription = zoomStream.listen((event) {
      _scrollEnabled = !event;
    });

    _context = context;
  }

  bool _scrollEnabled = true;

  BuildContext? _context;

  ZoomControllerSubscription? _zoomControllerSubscription;

  // ---------------------------------------------------------------------------
  static PinchLockablePhysics build(BuildContext context) {
    final ScrollPhysics scrollPhysics;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        scrollPhysics = const BouncingScrollPhysics(
            parent: RangeMaintainingScrollPhysics());
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        scrollPhysics = const ClampingScrollPhysics(
            parent: RangeMaintainingScrollPhysics());
        break;
      default:
        scrollPhysics = const BouncingScrollPhysics();
    }
    return PinchLockablePhysics._(scrollPhysics, context);
  }

  // ------------------------------------------------------------------
  void dispose() {
    _zoomControllerSubscription?.cancel();
  }

  // ------------------------------------------------------------------
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (_scrollEnabled) {
      return super.applyPhysicsToUserOffset(position, offset);
    } else {
      return 0;
    }
  }

  // ------------------------------------------------------------------
  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PinchLockablePhysics._(buildParent(ancestor), _context);
  }

  // ------------------------------------------------------------------
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (_scrollEnabled) {
      return super.createBallisticSimulation(position, velocity);
    } else {
      return null;
    }
  }
}
