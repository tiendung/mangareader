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
                children: manga.chapters
                    .map((chapter) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterScreen(chapter: chapter),
                            ),
                          );
                        },
                        child: Text('${chapter.title}: ${chapter.url}')))
                    .toList())));
  }
}
