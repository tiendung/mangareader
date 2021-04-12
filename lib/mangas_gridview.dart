import 'dart:collection';

import 'package:flutter/material.dart';
import 'chapter_screen.dart';
import 'manga_isar.dart';
import 'manga_data.dart';
import 'manga_item.dart';

class MangasGridView extends StatelessWidget {
  final SplayTreeSet<Manga> mangas;
  final int? count;
  MangasGridView({required this.mangas, this.count});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count == null ? 4 : count!,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 334.0 / 225.0, // itemWidth / itemHeight
      ),
      padding: EdgeInsets.only(bottom: 10, top: 5, right: 5),
      scrollDirection: Axis.horizontal,
      itemCount: mangas.length,
      itemBuilder: (BuildContext context, int index) {
        final manga = mangas.elementAt(index);
        return GestureDetector(
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterScreen(
                      manga: manga, chapterUrl: manga.firstChapterUrl()),
                ),
              );
            }, // onLongPress
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterScreen(
                      manga: manga, chapterUrl: manga.defaultChapterUrl()),
                ),
              );
            }, // onTap
            child: MangaItem(manga: manga));
      }, // itemBuilder
    );
  }
}
