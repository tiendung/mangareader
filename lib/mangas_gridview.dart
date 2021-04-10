import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chapter_screen.dart';
import 'manga_isar.dart';
import 'constants.dart';

class MangasGridView extends StatelessWidget {
  final List<Manga> mangas;
  MangasGridView({required this.mangas});

  @override
  Widget build(BuildContext context) {
    mangas.sort((a, b) => -a.compareValue().compareTo(b.compareValue()));
    return GridView.count(
      padding: EdgeInsets.only(bottom: 10, top: 5, right: 5),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      crossAxisCount: 4,
      scrollDirection: Axis.horizontal,
      childAspectRatio: 334.0 / 225.0, // itemWidth / itemHeight
      children: mangas
          .map((manga) => GestureDetector(
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
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
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(manga.coverImageUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      boxShadow: [
                        BoxShadow(
                            color: Constants.softHighlightColor,
                            offset: Offset(-4, -4),
                            spreadRadius: 0,
                            blurRadius: 4),
                        BoxShadow(
                            color: Constants.softShadowColor,
                            offset: Offset(4, 4),
                            spreadRadius: 0,
                            blurRadius: 4),
                      ]),
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
                          backgroundColor: Constants.backgroundColor,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ))))
          .toList(),
    );
  }
}
