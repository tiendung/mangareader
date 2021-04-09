import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'mangas_provider.dart';
import 'manga_data.dart';
import 'mangas_gridview.dart';

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

    var now = DateTime.now();
    var map = <String, List<Manga>>{};
    for (var manga in mangas) {
      final d = now.difference(manga.updatedAt).inDays;
      String k = "";
      if (d <= 1) {
        k = "Today";
      } else if (d <= 3) {
        k = "Two Days Ago";
      } else if (d <= 7) {
        k = "Last Week";
      } else if (d <= 14) {
        k = "Last Two Weeks";
      } else if (d <= 30) {
        k = "Last Month";
      }
      if (k != "" && manga.rate >= 4.5) {
        (map[k] ??= []).add(manga);
      }
    }

    void _handleRefreshPressed() async {
      final mangasNotifier = context.read(mangasProvider.notifier);
      mangasNotifier.update();
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
            // content: Text(map.values.elementAt(index)[0].title),
            content: Container(
              height: 600,
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
