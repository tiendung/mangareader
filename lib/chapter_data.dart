import 'package:isar/isar.dart';
import 'manga_data.dart';
import 'package:dio/dio.dart';

@Collection()
class Chapter {
  @Id()
  int? id;

  String title = "";

  String url = "";

  int viewingImageIndex = -1;

  List<String> imageUrls = [];

  DateTime createdAt = DateTime.now();

  var manga = IsarLink<Manga>();

  bool visited() => viewingImageIndex != -1;

  Future<void> crawl() async {
    if (imageUrls.length > 0) {
      return;
    }
    var response = await Dio()
        .get(url); // https://manganelo.com/chapter/go922760/chapter_78
    final str = response.data.toString().split("container-chapter-reader").last;
    // <img src="https://s8.mkklcdnv6temp.com/mangakakalot/g2/go922760/chapter_78/47.jpg" alt="The Great Mage Returns After 4000 Years Chapter 78 page 47 - MangaNelo.com" title="The Great Mage Returns After 4000 Years Chapter 78 page 47 - MangaNelo.com" style="margin-top: 5px;">
    final exp = RegExp(r'<img src="(.+?)" alt="');
    Iterable<RegExpMatch> matches = exp.allMatches(str);
    imageUrls = matches.map((e) => e[1]!).toList();
  }
}
