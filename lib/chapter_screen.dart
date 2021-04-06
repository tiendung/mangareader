import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'chapter_data.dart';

class ChapterScreen extends StatefulWidget {
  WebViewController? _controller;
  final Chapter chapter;
  ChapterScreen({required this.chapter});
  @override
  ChapterScreenState createState() => ChapterScreenState();
}

class ChapterScreenState extends State<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
        initialUrl: widget.chapter.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          // https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController/evaluateJavascript.html
          widget._controller = webViewController;
        },
        onPageFinished: (_) {
          final js = '''
          document.querySelectorAll("div.container")[2].style.display = "none";
          var m = document.querySelectorAll("div.container>div");
          m.forEach(function(e,i) { if (i==2||i==4) e.style.paddingTop = "2em"; else e.style.display = "none"; });
          document.querySelector(".body-site>div:nth-of-type(2)").style.display = "none";
          document.querySelector(".body-site>div:nth-of-type(4)").style.display = "none";
          document.querySelector(".container-chapter-reader>div").style.display = "none";
        ''';
          widget._controller!.evaluateJavascript(js);
        });
  }
}

/*
class ChapterScreen extends StatelessWidget {
  final Chapter chapter;
  ChapterScreen({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(chapter.title),
        ),
        body: WebView(initialUrl: chapter.url)
        // ListView.builder(
        //   itemBuilder: (BuildContext ctx, int index) {
        //     return Image.network(chapter.imageUrls[index]);
        //   },
        //   itemCount: chapter.imageUrls.length,
        // ),
        );
  }
}

      // initialUrl: Uri.dataFromString(
      //         '<html><body><img src="${widget.chapter.imageUrls[0]}"></body></html>',
      //         mimeType: 'text/html')
      //     .toString()

*/