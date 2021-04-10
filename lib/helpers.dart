import 'dart:io' show Platform;
import 'manga_data.dart';

const MIN_RATE = 4.6;
const MIN_VIEWS = 300000;
const MAX_UPDATED_DAYS = 30;
// ignore: non_constant_identifier_names
final MAX_PAGE = Platform.isAndroid ? 65 : 5;

String dayDiffToStr(d) {
  if (d <= 1) {
    return "Today";
  } else if (d <= 3) {
    return "Two Days Ago";
  } else if (d <= 7) {
    return "Last Week";
  } else if (d <= 14) {
    return "Last Two Weeks";
  } else if (d <= 30) {
    return "Last Month";
  } else {
    return "";
  }
}

void groupMangasByUpdatedAt(List<Manga> mangas, Map<String, List<Manga>> map) {
  final now = DateTime.now();
  for (var manga in mangas) {
    final k = dayDiffToStr(now.difference(manga.updatedAt).inDays);
    if (k != "" && manga.rate >= MIN_RATE) {
      (map[k] ??= []).add(manga);
      // if (manga.url == "https://manganelo.com/manga/the_wrong_way_to_use_healing_magic") print("\n- - - - \nFOUND: $k, ${manga.toStr()}");
    }
  }
}