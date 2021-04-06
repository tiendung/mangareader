import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'chapter_data.dart';

class ChapterScreen extends StatefulWidget {
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
      // initialUrl: Uri.dataFromString(
      //         '<html><body><img src="${widget.chapter.imageUrls[0]}"></body></html>',
      //         mimeType: 'text/html')
      //     .toString()

      initialUrl: widget.chapter.url,
      javascriptMode: JavascriptMode.disabled,
    );
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
*/