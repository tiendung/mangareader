import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'manga_isar.dart';
import 'manga_data.dart';
import 'mangas_provider.dart';
import 'mangas_gridview.dart';
import 'constants.dart';

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
    final map = Map<String, int>();
    MangaHelpers.groupMangasByUpdatedAt(mangas, map);

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
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            content: Container(
              height: 740,
              child: MangasGridView(
                  mangas: mangas,
                  begin: index == 0 ? 0 : map.values.elementAt(index - 1) + 1,
                  end: map.values.elementAt(index)),
            ),
          );
        },
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read(mangasProvider.notifier).load(),
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blueGrey.withOpacity(0.8),
      ),
    );
  }
}
