This package helps to create a scrollable set of widgets containing images with zoom effect.
This approach can be applied to different types of scrolling.

ListView

![Zoom_demo](https://github.com/dadrum/pinch_scrollable/blob/main/doc/vertical.gif?raw=true)

CarouselSlider

![Zoom_demo](https://github.com/dadrum/pinch_scrollable/blob/main/doc/carousel.gif?raw=true)

and other

## Features

Images can be enlarged with a pinch. When released, they regain their position and size.
The package has a special tool that allow to turn off scrolling in the list during image magnification

## Getting started

Add the dependency to your `pubspec.yaml`:
```
pinch_scrollable: ^1.0.1
```


## Usage

The effect is achieved when using:  
PinchScrollableArea - a zone displaying image's zooming;  
PinchItemContainer - а container that accepts gestures and contains an image inside that needs to be enlarged;  
PinchScrollLockPhysics - special physics that prevents scrolling of the list.  

Simplified code structure: 
```dart
PinchScrollableArea(
  ...
    Builder(
      builder: (context) => ListView(
        physics: PinchScrollLockPhysics.build(context),
        itemBuilder: (context, index) {
          final key = GlobalKey();
          return PinchItemContainer(
            imageWidgetKey: key,
            imageUrl: imageUrl,
            child: CachedNetworkImage(
              key: key,
              imageUrl: imageUrl,
            ),
          );
        },
      ),
    )
)
```

The Builder widget is used so PinchScrollLockPhysics can use the PinchScrollableArea's state.
There is an approach not to use the Builder located in the example folder. 
The key is required for use and is needed to determine the image parameters.
