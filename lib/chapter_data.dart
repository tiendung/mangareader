import 'package:isar/isar.dart';
import 'manga_data.dart';

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
}
