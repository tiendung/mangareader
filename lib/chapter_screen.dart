import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChapterScreen extends StatefulWidget {
  final String chapterUrl;
  ChapterScreen({required this.chapterUrl});
  @override
  ChapterScreenState createState() => ChapterScreenState();
}

class ChapterScreenState extends State<ChapterScreen> {
  late WebViewController? _controller;
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    var jsRun = false;
    return WebView(
        initialUrl: widget.chapterUrl,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: 'Print',
              onMessageReceived: (m) {
                print(m.message);
              }),
          JavascriptChannel(
              name: 'HideUnwantedElems',
              onMessageReceived: (m) {
                jsRun = true;
                final js = '''
          var n = document.querySelector(".navi-change-chapter-btn-next");
          GetNextChapUrl.postMessage(n.href);
          ''';
                _controller!.evaluateJavascript(js);
              }),
          JavascriptChannel(
              name: 'GetNextChapUrl',
              onMessageReceived: (m) async {
                print('GET NEXT CHAP ${m.message}');
                var response = await Dio().get(m.message);
                final str = response.data
                    .toString()
                    .split("container-chapter-reader")
                    .last;
                final exp = RegExp(r'<img src="(.+?)" alt="');
                Iterable<RegExpMatch> matches = exp.allMatches(str);
                final imageUrls = matches.map((e) => e[1]!);
                final String nextChapImgs = imageUrls
                    .map((e) => '<img src="$e" style="margin-top: 0px;">')
                    .join();
                final nextChapId = m.message.split('chapter_').last;
                final js = '''
          document.nextChapDiv = document.querySelector(".body-site>div:nth-of-type(4)");
          document.nextChapDiv.style = "display:none;";
          document.nextChapId = "$nextChapId";
          document.nextChapContent = '$nextChapImgs';
          document.nextChapDiv.innerHTML = document.nextChapContent;
          if (!document.nextChapButtonsBinded) {
            document.querySelectorAll(".navi-change-chapter-btn-next").forEach(function(n,i) {
              n.onclick = function (e) { 
                e.preventDefault();
                document.querySelector(".container-chapter-reader").innerHTML = document.nextChapContent;
                var x = document.querySelector(".navi-change-chapter>option[selected]"); if (x) x.removeAttribute("selected");
                var x = document.querySelector(".navi-change-chapter>option[selected='selected']"); if (x) x.removeAttribute("selected");
                x = document.querySelector(".navi-change-chapter>option[data-c='"+document.nextChapId+"']");
                // Print.postMessage(x.innerHTML);
                x.selected = "selected";
                window.scrollTo(0, 0);
                if (x.previousSibling) {
                  GetNextChapUrl.postMessage(location.href.split("chapter_")[0]+"chapter_"+x.previousSibling.getAttribute("data-c"));
                } else { this.style.display="none"; }
              };
            });
            document.nextChapButtonsBinded = true;
          };
          ''';
                print(js);
                _controller!.evaluateJavascript(js);
              }),
        ]),
        onWebViewCreated: (webViewController) {
          _controller = webViewController;
        },
        onPageStarted: (_) {
          jsRun = false;
        },
        onProgress: (_) {
          if (jsRun) return;
          // hide unwanted HTML elements
          final js = '''
          document.querySelectorAll("div.container")[2].style.display = "none";
          var m = document.querySelectorAll("div.container>div");
          m.forEach(function(e,i) { if (i==2||i==4) e.style.paddingTop = "2em"; else e.style.display = "none"; });
          document.querySelector(".body-site>div:nth-of-type(2)").style.display = "none";
          document.querySelector(".body-site>div:nth-of-type(4)").style.display = "none";
          m = document.querySelectorAll("div.container-chapter-reader>div");
          m.forEach(function(e,i) { e.style.display = "none"; });
          document.querySelectorAll(".navi-change-chapter")[1].style.display = "none";
          HideUnwantedElems.postMessage("DONE");
        ''';
          _controller!.evaluateJavascript(js);
        });
  }
}
