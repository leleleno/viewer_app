import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/data/favoritedata.dart';
import 'package:first_app/data/historydata.dart';
import 'package:first_app/data/settingsdata.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_v3/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

class CardView extends StatelessWidget {
  const CardView({super.key, required this.pageUrl, required this.cardName});

  final String pageUrl;
  final String cardName;

  @override
  Widget build(BuildContext context) {
    int selectedIndex = -1;
    // FAB visibility
    // bool isVisible = true;
    return CommonScaffold(
      title: cardName,
      index: selectedIndex,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: fetchCardData(context, pageUrl),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return SelectableText('Network Error: ${snapshot.error}');
            } else {
              return Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final settings = ref.watch(settingsNotifierProvider);
                  Future.delayed(Duration.zero, () {
                    // 履歴に追加
                    final notifier = ref.read(historyNotifierProvider.notifier);
                    notifier.addData(cardName, pageUrl);
                  });
                  return Html(
                      data: snapshot.data,
                      onLinkTap: (String? url,
                          RenderContext renderContext,
                          Map<String, String> attributes,
                          dom.Element? element) {
                        if (url == null) {
                        } else if (RegExp(r"yugioh-wiki\.net").hasMatch(url)) {
                          String newUrl = url.replaceAll(
                              RegExp(r"(:443|cmd=read&page=|&word=.*$)"), "");
                          String newCardName = attributes["title"]!
                              .replaceAll(RegExp(r" +\(.+\)$"), "");
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => CardView(
                                pageUrl: newUrl, cardName: newCardName),
                            settings: RouteSettings(name: '/card/$newCardName'),
                          ));
                        } else {
                          if (settings['checkLink']) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('外部リンクを開きます'),
                                    content: Text(url),
                                    actions: [
                                      GestureDetector(
                                        child: const Text("キャンセル"),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      GestureDetector(
                                        child: const Text('続行'),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          launchUrlString(url);
                                        },
                                      )
                                    ],
                                  );
                                });
                          } else {
                            launchUrlString(url);
                          }
                        }
                      });
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          // favorite control
          final favorites = ref.watch(favoriteNotifierProvider);
          return FloatingActionButton(
              onPressed: () {
                var notifier = ref.read(favoriteNotifierProvider.notifier);
                favorites.containsKey(cardName)
                    ? notifier.removeData(cardName)
                    : notifier.addData(cardName, pageUrl);
              },
              tooltip: favorites.containsKey(cardName)
                  ? "Remove from Favorite"
                  : "Add to Favorite",
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: const CircleBorder(),
              child: Icon(
                favorites.containsKey(cardName)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: const Color.fromARGB(255, 252, 158, 189),
              ));
        },
      ),
    );
  }
}

Future<String> fetchCardData(BuildContext context, String? pageUrl) async {
  // 取得先のURLを元にして、Uriオブジェクトを生成する。
  final response = await http.get(
    Uri.parse(pageUrl!),
  );
  // responseの成否で判定
  if (response.statusCode != 200) {
    return "Cannot get the data.";
  }
  // EUC-JP decode
  final decodedBody =
      await CharsetConverter.decode("EUC-JP", response.bodyBytes);
  // htmlをパース
  final document = parse(decodedBody);
  // htmlの内容で分岐
  final body = document.querySelector('#body');
  if (body == null) {
    return "No data in the page.";
  }
  // Clear tags
  List<String> selectors = [
    ".jumpmenu",
    ".anchor_super",
    "div",
    "br",
    "table",
    ".tag"
  ];
  for (String selector in selectors) {
    body.querySelectorAll(selector).forEach((element) {
      element.remove();
    });
  }
  // Stringにして全角スペース、ダガー、コメントアウト削除
  String html = body.outerHtml
      .replaceAll(RegExp(r"([　†]|<!--.*-->|)"), "")
      .replaceAll(RegExp(r"、\n"), "、")
      .replaceAll(RegExp(r"(<rb>|<\/rb>|<div.*>|<\/div>|<hr.*>|<p><\/p>)"), "");
  // return SelectableText(html);
  return html;
}
