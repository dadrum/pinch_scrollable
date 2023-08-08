import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pinch_scrollable/pinch_scrollable.dart';

void main() {
  runApp(const MyApp());
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyListPage(),
    );
  }
}

class MuseumDetails {
  const MuseumDetails({
    required this.title,
    required this.details,
    required this.imageUrl,
  });

  final String title;
  final String details;
  final String imageUrl;
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PinchScrollableArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Pinch scrollable demo'),
          ),
          backgroundColor: Colors.white70,
          body: _MuseumsList()),
    );
  }
}

class _MuseumsList extends StatelessWidget {
  const _MuseumsList({Key? key}) : super(key: key);

  static const _museums = const <MuseumDetails>[
    const MuseumDetails(
      title: 'Louvre Museum',
      details:
          'The Louvre Museum in Paris is the largest art museum in the world.',
      imageUrl:
          'https://image.wmsm.co/eef1ef270f8045c067c3646caa7047b3/louvre-museum-paris-1.jpg?quality=80&width=1280',
    ),
    const MuseumDetails(
      title: 'Musée Rodin',
      details:
          'Visit the former workshop of the founder of modern sculpting - Auguste Rodin. Opened in 1919, the Musée Rodin museum houses a great collection of his works.',
      imageUrl:
          'https://image.wmsm.co/644942ebccdd976e0a4cf9b86844216b/musee-rodin-paris-1.jpg?quality=80&width=1280',
    ),
    const MuseumDetails(
      title: 'City of Paris Fine Art Museum',
      details:
          'The City of Paris Fine Art Museum is housed in the Petit Palais in Paris, which was built for the 1900 World\'s Fair by the architect Charles Girault.',
      imageUrl:
          'https://image.wmsm.co/a80749b800d2cecffada73c87b236635/city-of-paris-fine-art-museum-1.jpg?quality=80&width=1280',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _museums.length,
      physics: PinchScrollLockPhysics.build(context),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final details = _museums.elementAt(index);
        final imageKey = GlobalKey();
        return PinchItemContainer(
          imageWidgetKey: imageKey,
          imageUrl: details.imageUrl,
          child: MuseumDetailsWidgetMuseum(
            museum: details,
            imageKey: imageKey,
          ),
        );
      },
      padding: EdgeInsets.all(16),
    );
  }
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
class MuseumDetailsWidgetMuseum extends StatelessWidget {
  const MuseumDetailsWidgetMuseum({
    Key? key,
    required this.museum,
    required this.imageKey,
  }) : super(key: key);

  final MuseumDetails museum;
  final GlobalKey imageKey;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CachedNetworkImage(
              key: imageKey,
              imageUrl: museum.imageUrl,
            ),
            const SizedBox(height: 8),
            Text(
              museum.title,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              museum.details,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
