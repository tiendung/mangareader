import 'package:isar/isar.dart';
import 'chapter_data.dart';
import 'package:dio/dio.dart';

@Collection()
class Manga {
  @Id()
  int? id;

  @Index(indexType: IndexType.words) // Search index
  String title = "";

  String coverImageUrl = "";

  String url = "";

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  @Backlink(to: 'manga')
  var chapters = IsarLinks<Chapter>(); // Link to other collection

  Future<void> crawl() async {
    var response = await Dio().get(url); // https://manganelo.com/manga/go922760
    final str = response.data.toString();
    final exp = RegExp(r'class="chapter-name.+?href="(.+?)".+?>(.+?)</a>');
    Iterable<RegExpMatch> matches = exp.allMatches(str);
    for (var match in matches) {
      if (chapters.any((c) => c.url == match[1])) {
        break;
      } else {
        final c = Chapter();
        c.title = match[2]!;
        c.url = match[1]!;
        chapters.add(c);
      }
    }
    title = RegExp(r'<h1>(.+?)</h1>').firstMatch(str)![1]!;
    // <img class="img-loading" src="https://avt.mkklcdnv6temp.com/7/f/21-1588309436.jpg" alt="The Great Mage Returns After 4000 Years"
    coverImageUrl = RegExp(r'src="(.+?jpg)" alt="').firstMatch(str)![1]!;
  }
}
