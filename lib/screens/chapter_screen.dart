import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:mangareader/data/manga_data.dart';
import 'package:mangareader/data/manga_floor.dart';

import 'package:mangareader/screens/chapter_screen_js.dart' as JavaScript;

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
    var jsRun = 0;
    print('\n- - - - - - - - - - - - -\nREADING: ${widget.manga.toStr()}\n\n');

    return Scaffold(
      body: WebView(
        initialUrl: widget.chapterUrl,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: 'Print',
              onMessageReceived: (m) {
                print(m.message);
              }),
          JavascriptChannel(
              name: 'UpdateCurrentScrollY',
              onMessageReceived: (m) {
                widget.manga.updateCurrentScrollY(m.message);
              }),
          JavascriptChannel(
              name: 'UpdateCurrentReading',
              onMessageReceived: (m) {
                widget.manga.updateCurrentReading(m.message);
              }),
          JavascriptChannel(
              name: 'HideUnwantedElems',
              onMessageReceived: (m) {
                jsRun = 1;
                _controller!
                    .evaluateJavascript(JavaScript.getNextChapUrlJs);
              }),
          JavascriptChannel(
              name: 'GetNextChapUrl',
              onMessageReceived: (m) async {
                _controller!.evaluateJavascript(
                    await JavaScript.nextChapJs(m.message));
              }),
        ]),
        onWebViewCreated: (webViewController) {
          _controller = webViewController;
        },
        onPageStarted: (_) {
          jsRun = 0;
        },
        onPageFinished: (_) {},
        onProgress: (_) {
          if (jsRun > 0) return;
          _controller!.evaluateJavascript(
              JavaScript.hideUnwantedElemsJsAndScroll(
                widget.chapterUrl == widget.manga.currentChapterUrl ?
                  widget.manga.currentScrollY : 0));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: 'Back',
        child: Icon(Icons.arrow_back_ios),
        backgroundColor: Colors.blueGrey.withOpacity(0.3),
      ),
    );
  }
}
