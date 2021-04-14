import 'package:flutter/material.dart';

import 'package:mangareader/constants.dart';
import 'package:mangareader/data/manga_data.dart';
import 'package:mangareader/data/manga_floor.dart';

class MangaItem extends StatelessWidget {
  final Manga manga;
  MangaItem({required this.manga});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(manga.coverImageUrl),
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
        ));
  }
}
