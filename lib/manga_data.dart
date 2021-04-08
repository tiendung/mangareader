import 'package:isar/isar.dart';
import 'package:dio/dio.dart';

@Collection()
class Manga {
  @Id()
  int? id;

  @Index(indexType: IndexType.words) // Search index
  String title = "";

  String coverImageUrl = "";

  String url = "";

  double rate = 4.5;

  List<String> chapterUrls = [];

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  String lastChapterUrl() {
    if (chapterUrls.length > 0) return chapterUrls.first;
    return "";
  }

  Future<void> crawl() async {
    var response = await Dio().get(url); // https://manganelo.com/manga/go922760
    final str = response.data.toString();
    final exp = RegExp(r'class="chapter-name.+?href="(.+?)".+?>(.+?)</a>');
    Iterable<RegExpMatch> matches = exp.allMatches(str);
    for (var i = 0; i < matches.length; i++) {
      final url = matches.elementAt(i)[1]!;
      if (chapterUrls.length > i && url == chapterUrls[i]) {
        break;
      } else {
        chapterUrls.insert(i, url);
      }
    }
    title = RegExp(r'<h1>(.+?)</h1>').firstMatch(str)![1]!;
    coverImageUrl = RegExp(r'src="(.+?jpg)" alt="').firstMatch(str)![1]!;
  }
}
