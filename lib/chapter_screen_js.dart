import 'package:dio/dio.dart';

final getNextChapUrlJs = '''
    var n = document.querySelector(".navi-change-chapter-btn-next");
    GetNextChapUrl.postMessage(n.href);
''';

final hideUnwantedElemsJs = '''
    document.querySelectorAll("div.container")[2].style.display = "none";
    document.querySelectorAll("div.container>div").forEach(function(e,i) { if (i==2||i==4) e.style.paddingTop = "2em"; else e.style.display = "none"; });
    document.querySelector(".body-site>div:nth-of-type(2)").style.display = "none";
    document.querySelector(".body-site>div:nth-of-type(4)").style.display = "none";
    document.querySelectorAll("div.container-chapter-reader>div").forEach(function(e,i) { e.style.display = "none"; });
    Print.postMessage('HA HA');
    document.querySelectorAll(".navi-change-chapter")[1].style.display = "none";
    document.querySelectorAll(".navi-change-chapter-btn-prev").forEach(function(e,i) { e.style.display = "none"; });
    document.querySelectorAll(".navi-change-chapter-btn-next").forEach(function(e,i) { e.style.display = "none"; });
    HideUnwantedElems.postMessage("DONE");
''';

Future<String> nextChapJs(String url) async {
  // print('GET NEXT CHAP $url');
  var response = await Dio().get(url);
  final str = response.data.toString().split("container-chapter-reader").last;
  final exp = RegExp(r'<img src="(.+?)" alt="');
  Iterable<RegExpMatch> matches = exp.allMatches(str);
  final imageUrls = matches.map((e) => e[1]!);
  final String nextChapImgs =
      imageUrls.map((e) => '<img src="$e" style="margin:0px;">').join();
  final nextChapId = url.split('chapter_').last;

  return '''
  document.nextChapDiv = document.querySelector(".body-site>div:nth-of-type(4)");
  document.nextChapDiv.style = "display:none;";
  document.nextChapId = "$nextChapId";
  document.nextChapContent = '$nextChapImgs';
  document.nextChapDiv.innerHTML = document.nextChapContent;
  document.reachBottomCount = 1;

  if (!document.nextChapButtonsBinded) {

    document.querySelectorAll(".navi-change-chapter-btn-next").forEach(function(n,i) {
      n.onclick = function (e) { 
        e.preventDefault();
        document.querySelector(".container-chapter-reader").innerHTML = document.nextChapContent;
        document.nextChapDiv.innerHTML = "";
        x = document.querySelector(".navi-change-chapter>option[data-c='"+document.nextChapId+"']");
        x.selected = "selected";
        window.scrollTo(0, 0);
        if (x.previousSibling) {
          GetNextChapUrl.postMessage(location.href.split("chapter_")[0]+"chapter_"+x.previousSibling.getAttribute("data-c"));
        } else { this.style.display="none"; }
        UpdateCurrentReading.postMessage(document.location.href.split('chapter_')[0] + 'chapter_' + x.nextSibling.getAttribute("data-c"));
      };
    });

    document.addEventListener('scroll', function (event) {
        if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight-document.reachBottomCount) {
            if (document.reachBottomCount > 100) {
              document.querySelector(".navi-change-chapter-btn-next").click();
              return;
            }
            Print.postMessage("REACH BOTTOM OF THE PAGE");
            document.reachBottomCount = 110;
        }
    });

    document.nextChapButtonsBinded = true;
  } // if (!document.nextChapButtonsBinded)
  ''';
}
