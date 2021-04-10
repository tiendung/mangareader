import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'mangas_provider.dart';
import 'manga_isar.dart';
import 'mangas_gridview.dart';
import 'helpers.dart';

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
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mangas = watch(mangasProvider);
    final map = Map<String, List<Manga>>();
    groupMangasByUpdatedAt(mangas, map);

    void _handleRefreshPressed() async {
      final mangasNotifier = context.read(mangasProvider.notifier);
      mangasNotifier.update();
    }

    return Scaffold(
      // appBar: AppBar(title: Text("Latest")),
      body: Center(
          child: ListView.builder(
        itemCount: map.length,
        itemBuilder: (context, index) {
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Colors.blueGrey[700],
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                map.keys.elementAt(index),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            content: Container(
              height: 740,
              child: MangasGridView(mangas: map.values.elementAt(index)),
            ),
          );
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleRefreshPressed,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
