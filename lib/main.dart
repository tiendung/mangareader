import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mangas_provider.dart';
import 'chapter_screen.dart';
import 'manga_screen.dart';

void main() {
  runApp(ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mangas = watch(mangasProvider);
    // context.read(mangasProvider.notifier).refresh();

    void _handleRefreshPressed() async {
      final mangasNotifier = context.read(mangasProvider.notifier);
      await mangasNotifier.update(1);
      mangasNotifier.load();
      await mangasNotifier.update(2);
      mangasNotifier.load();
      await mangasNotifier.update(3);
      mangasNotifier.load();
      await mangasNotifier.update(4);
      mangasNotifier.load();
      await mangasNotifier.update(5);
      mangasNotifier.load();
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Latest"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: GridView.count(
          padding: EdgeInsets.all(10.0),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 225.0 / 334.0, // itemWidth / itemHeight
          children: mangas
              .map((manga) => GestureDetector(
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MangaScreen(manga: manga),
                      ),
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChapterScreen(chapterUrl: manga.lastChapterUrl()),
                      ),
                    );
                  },
                  child: Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              CachedNetworkImageProvider(manga.coverImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Opacity(
                        opacity: 0.9,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '${manga.title} (${manga.lastChapterUrl().split('chapter_').last})',
                            // textAlign: TextAlign.center,
                            // overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 15,
                              backgroundColor: Colors.black,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ))))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleRefreshPressed,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
