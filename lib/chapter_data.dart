import 'package:isar/isar.dart';
import 'manga_data.dart';

@Collection()
class Chapter {
  @Id()
  int? id;

  String title = "";

  bool visited = false;

  int viewingImageIndex = -1;

  List<String> imageUrls = [];

  var manga = IsarLink<Manga>();
}
