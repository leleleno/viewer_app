import 'package:charset_converter/charset_converter.dart';
import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_v3/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher_string.dart';
part 'card.g.dart';

@riverpod
class FavoriteNotifier extends _$FavoriteNotifier {
  @override
  Map<String, bool> build() {
    return {};
  }

  void updateState(String name, bool fav) {
    state[name] = fav;
  }
}

class CardView extends StatefulWidget {
  const CardView({super.key, required this.pageUrl, required this.cardName});

  final String? pageUrl;
  final String? cardName;

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  final int _selectedIndex = -1;

  ValueNotifier<bool> _is_favorite = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, widget.cardName!),
      drawer: myDrawer(context, _selectedIndex),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // ページコンテンツ、非同期処理なのでFuturebuilder
              FutureBuilder(
                future: fetchCardData(context, widget.pageUrl),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return SelectableText('Network Error: ${snapshot.error}');
                  } else {
                    return snapshot.data!;
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _is_favorite.value = !_is_favorite.value;
        },
        tooltip: "Add to Favorite",
        child: ValueListenableBuilder(
            valueListenable: _is_favorite,
            builder: (context, value, child) {
              return Icon(
                value ? Icons.favorite : Icons.favorite_border,
              );
            }),
      ),
    );
  }
}

Future<Widget> fetchCardData(BuildContext context, String? pageUrl) async {
  // 取得先のURLを元にして、Uriオブジェクトを生成する。
  final response = await http.get(
    Uri.parse(pageUrl!),
  );
  // responseの成否で判定
  if (response.statusCode != 200) {
    return const Text("Cannot get the data.");
  }
  // EUC-JP decode
  final decodedBody =
      await CharsetConverter.decode("EUC-JP", response.bodyBytes);
  // htmlをパース
  final document = parse(decodedBody);
  // htmlの内容で分岐
  final body = document.querySelector('#body');
  if (body == null) {
    return const Text("No data in the page.");
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
      .replaceAll(RegExp(r"([　†]|<!--.*-->)"), "")
      .replaceAll(RegExp(r"(<rb>|<\/rb>|<div.*>|<\/div>)"), "");
  // return SelectableText(html);
  return Html(
      data: html,
      onLinkTap: (String? url, RenderContext context,
          Map<String, String> attributes, dom.Element? element) {
        if (RegExp(r"https://yugioh-wiki.net").hasMatch(url!)) {
          String newUrl =
              url.replaceAll(RegExp(r"(:443|cmd=read&page=|&word=.*$)"), "");
          // print(newUrl);
          // print(attributes["text"]!.replaceAll(RegExp(r"(.+)$"), ""));
          Navigator.of(context as BuildContext).push(MaterialPageRoute(
              builder: (BuildContext context) => CardView(
                  pageUrl: newUrl,
                  cardName:
                      attributes["text"]!.replaceAll(RegExp(r"(.+)$"), ""))));
        } else {
          launchUrlString(url);
        }
      });
}

dom.Element getContentBetweenHeaders(int index, dom.Element body) {
  // header get
  List<dom.Element> headers = body.querySelectorAll('h2, h3');

  if (index < 0 || index >= headers.length) {
    throw ArgumentError('index is out of range');
  }

  dom.Element start = headers[index];
  dom.Element? end = index + 1 < headers.length ? headers[index + 1] : null;
  List<dom.Element> retList = [start];
  dom.Element? next = start.nextElementSibling;

  while (next != end && next != null) {
    retList.add(next);
    next = next.nextElementSibling;
  }
  // Join all elements in retList into one string
  String allElements = retList.map((e) => e.outerHtml).join('');

  // Create a new Element with allElements as its innerHtml
  dom.Element result = dom.Element.tag('div');
  result.innerHtml = allElements;
  return result;
}
