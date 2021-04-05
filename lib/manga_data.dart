import 'package:isar/isar.dart';
import 'chapter_data.dart';

@Collection()
class Manga {
  @Id()
  int? id;

  @Index(indexType: IndexType.words) // Search index
  String title = "";

  String description = "";

  String url = "";

  @Backlink(to: 'mana')
  var chapters = IsarLinks<Chapter>(); // Link to other collection
}
