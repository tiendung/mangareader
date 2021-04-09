import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chapter_screen.dart';
import 'manga_data.dart';

class MangasGridView extends StatelessWidget {
  final List<Manga> mangas;
  MangasGridView({required this.mangas});

  @override
  Widget build(BuildContext context) {
    mangas.sort((a, b) => -a.compareValue().compareTo(b.compareValue()));
    return GridView.count(
      padding: EdgeInsets.only(bottom: 8, top: 3),
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      crossAxisCount: 3,
      scrollDirection: Axis.horizontal,
      childAspectRatio: 334.0 / 225.0, // itemWidth / itemHeight
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
                  // width: 225,
                  // height: 334,
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
                        overflow: TextOverflow.visible,
                        // maxLines: 4,
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
