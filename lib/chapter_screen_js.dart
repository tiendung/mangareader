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

    UpdateCurrentReading.postMessage(document.location.href);
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
        // Show nextChap image
        document.querySelector(".container-chapter-reader").innerHTML = document.nextChapContent;
        document.nextChapDiv.innerHTML = "";
        // And update that user reading the next chap
        UpdateCurrentReading.postMessage(document.location.href.split('chapter_')[0] + 'chapter_' + document.nextChapId);
        window.scrollTo(0, 0);
        // window.scrollTo({top: 0, left: 0, behavior: 'smooth'});
        
        var x = document.querySelector(".navi-change-chapter>option[data-c='"+document.nextChapId+"']");
        x.selected = "selected";
        if (x.previousSibling) {
          GetNextChapUrl.postMessage(location.href.split("chapter_")[0]+"chapter_"+x.previousSibling.getAttribute("data-c"));
        } else { this.style.display="none"; }
      };
    });

    var scrollCount = 0;
    document.addEventListener('scroll', function (event) {
        if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight-document.reachBottomCount) {
          if (document.reachBottomCount > 100) {
            document.querySelector(".navi-change-chapter-btn-next").click();
            return;
          }
          Print.postMessage("REACH BOTTOM OF THE PAGE");
          document.reachBottomCount = 110;
        }
        scrollCount++;
        if (scrollCount == 60) {
          scrollCount = 0;
          UpdateCurrentScrollY.postMessage(window.scrollY);
        }
    });

    document.nextChapButtonsBinded = true;
  } // if (!document.nextChapButtonsBinded)
  ''';
}
