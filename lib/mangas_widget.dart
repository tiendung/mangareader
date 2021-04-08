import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chapter_screen.dart';
import 'manga_data.dart';

class MangasWidget extends StatelessWidget {
  final List<Manga> mangas;
  MangasWidget({required this.mangas});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.all(10.0),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      childAspectRatio: 225.0 / 334.0, // itemWidth / itemHeight
      children: mangas
          .map((manga) => GestureDetector(
              onLongPress: () {
                print(manga.firstChapterUrl());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // builder: (_) => MangaScreen(manga: manga),
                    builder: (_) => ChapterScreen(
                        manga: manga, chapterUrl: manga.firstChapterUrl()),
                  ),
                );
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChapterScreen(
                        manga: manga, chapterUrl: manga.defaultChapterUrl()),
                  ),
                );
              },
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(manga.coverImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Opacity(
                    opacity: 0.9,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        manga.fullTitle(),
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
    );
  }
}
