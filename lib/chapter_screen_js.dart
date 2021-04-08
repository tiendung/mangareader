import 'package:dio/dio.dart';

final getNextChapUrlJs = '''
    var n = document.querySelector(".navi-change-chapter-btn-next");
    GetNextChapUrl.postMessage(n.href);
''';

final hideUnwantedElemsJs = '''
    document.querySelectorAll("div.container")[2].style.display = "none";
    var m = document.querySelectorAll("div.container>div");
    m.forEach(function(e,i) { if (i==2||i==4) e.style.paddingTop = "2em"; else e.style.display = "none"; });
    document.querySelector(".body-site>div:nth-of-type(2)").style.display = "none";
    document.querySelector(".body-site>div:nth-of-type(4)").style.display = "none";
    m = document.querySelectorAll("div.container-chapter-reader>div");
    m.forEach(function(e,i) { e.style.display = "none"; });
    document.querySelectorAll(".navi-change-chapter")[1].style.display = "none";
    document.querySelectorAll(".navi-change-chapter-btn-prev")[0].style.display = "none";
    document.querySelectorAll(".navi-change-chapter-btn-prev")[1].style.display = "none";
    document.querySelectorAll(".navi-change-chapter-btn-next")[1].style = 'padding:4px; margin-bottom:15px;';
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
      imageUrls.map((e) => '<img src="$e" style="margin-top: 0px;">').join();
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
        var x = document.querySelector(".navi-change-chapter>option[selected]"); if (x) x.removeAttribute("selected");
        var x = document.querySelector(".navi-change-chapter>option[selected='selected']"); if (x) x.removeAttribute("selected");
        x = document.querySelector(".navi-change-chapter>option[data-c='"+document.nextChapId+"']");
        x.selected = "selected";
        window.scrollTo(0, 0);
        if (x.previousSibling) {
          GetNextChapUrl.postMessage(location.href.split("chapter_")[0]+"chapter_"+x.previousSibling.getAttribute("data-c"));
        } else { this.style.display="none"; }
      };
    });
    document.addEventListener('scroll', function (event) {
        if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight-document.reachBottomCount) {
            Print.postMessage("REACH BOTTOM OF THE PAGE");
            if (document.reachBottomCount > 100) {
              document.querySelector(".navi-change-chapter-btn-next").click();
            }
            document.reachBottomCount = 110;
        }
    });
    document.nextChapButtonsBinded = true;
  };
  ''';
}
