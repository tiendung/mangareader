import 'package:flutter/material.dart';
import 'manga_data.dart';
import 'chapter_screen.dart';

class MangaScreen extends StatelessWidget {
  final Manga manga;
  MangaScreen({required this.manga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(manga.title),
        ),
        body: Center(
            child: GridView.count(
                padding: EdgeInsets.all(10.0),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                childAspectRatio: 3, // itemWidth / itemHeight
                children: manga.chapterUrls
                    .map((chapterUrl) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChapterScreen(chapterUrl: chapterUrl),
                            ),
                          );
                        },
                        child: Text(
                          chapterUrl.split('/').last,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )))
                    .toList())));
  }
}
