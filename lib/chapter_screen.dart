import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'chapter_screen_js.dart' as ChapterScreenJs;
import 'manga_data.dart';

class ChapterScreen extends StatefulWidget {
  final Manga manga;
  final String chapterUrl;
  ChapterScreen({required this.manga, required this.chapterUrl});
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
              name: 'UpdateCurrentReading',
              onMessageReceived: (m) {
                widget.manga.updateCurrentReading(m.message);
              }),
          JavascriptChannel(
              name: 'HideUnwantedElems',
              onMessageReceived: (m) {
                jsRun = true;
                _controller!
                    .evaluateJavascript(ChapterScreenJs.getNextChapUrlJs);
              }),
          JavascriptChannel(
              name: 'GetNextChapUrl',
              onMessageReceived: (m) async {
                _controller!.evaluateJavascript(
                    await ChapterScreenJs.nextChapJs(m.message));
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
          _controller!.evaluateJavascript(ChapterScreenJs.hideUnwantedElemsJs);
        });
  }
}
