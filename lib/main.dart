import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'package:mangareader/constants.dart';
import 'package:mangareader/widgets/mangas_gridview.dart';
import 'package:mangareader/data/mangas_provider.dart';
import 'package:mangareader/data/manga_data.dart';
import 'package:mangareader/data/manga_floor.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(brightness: Brightness.light),
        scaffoldBackgroundColor: Constants.backgroundColor,
        backgroundColor: Constants.backgroundColor,
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
    final map = Map<String, SplayTreeSet<Manga>>();
    MangaHelpers.groupMangas(mangas, map);

    _toggle(String m) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }

    _updateNewMangas() async {
      if (!mangasCrawling) {
        _toggle('Loading new mangas ...');
        final total = await context.read(mangasProvider.notifier).updateNewest(5);
        _toggle('$total mangas updated');
      } else {
        _toggle('Updating in progress, please wait ...');
      }
    }

    return Scaffold(
      // appBar: AppBar(title: Text("Latest")),
      body: Center(
          child: RefreshIndicator(
              onRefresh: _updateNewMangas,
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
                          // fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    content: Container(
                      height: index == 0 ? 480 : 740,
                      child: MangasGridView(
                        mangas: map.values.elementAt(index),
                        count: index == 0 ? 3 : 4,
                      ),
                    ),
                  );
                },
              ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton(
          // tooltip: 'Refresh',
          onPressed: _updateNewMangas,
          child: Icon(Icons.refresh)),
    );
  }
}
