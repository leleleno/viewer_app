import 'package:first_app/data/searchdata.dart';
import 'package:first_app/data/settingsdata.dart';
import 'package:first_app/pages/favorite.dart';
import 'package:first_app/pages/history.dart';
import 'package:first_app/pages/search.dart';
import 'package:first_app/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CommonScaffold extends StatefulWidget {
  final String title;
  final int index;
  final Widget body;
  final Widget? floatingActionButton;

  const CommonScaffold({
    super.key,
    required this.title,
    required this.index,
    required this.body,
    this.floatingActionButton,
  });

  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

class _CommonScaffoldState extends State<CommonScaffold> {
  late bool isVisible;
  @override
  void initState() {
    super.initState();
    isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(index: widget.index),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            pinned: false,
            floating: true,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Visibility(
                visible: isVisible,
                child: const MySearchBar(
                  isFocus: true,
                )),
          ),
          SliverToBoxAdapter(
            child: widget.body,
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final settings = ref.watch(settingsNotifierProvider);
        bool isDark = settings['isDark'];
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary),
                child: const Center(child: Text('YGO wiki Viewer')),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('ホーム'),
                selected: index == 0,
                onTap: () {
                  // Drawer閉じる
                  Navigator.of(context).pop;
                  // Homeに戻る
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('検索'),
                    selected: index == 1,
                    onTap: () {
                      // ドロワー閉じる
                      Navigator.pop(context);
                      // もし検索画面じゃなかったら
                      if (index != 1) {
                        // 検索ワードリセット
                        // final notifier =
                        //     ref.read(searchWordNotifierProvider.notifier);
                        // notifier.addSearchWord("");
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Search(),
                          settings: const RouteSettings(name: "/search"),
                        ));
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('お気に入り'),
                selected: index == 2,
                onTap: () {
                  Navigator.pop(context);
                  if (index != 2) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Favorite(),
                      settings: const RouteSettings(name: "/favorite"),
                    ));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('履歴'),
                selected: index == 3,
                onTap: () {
                  Navigator.pop(context);
                  if (index != 3) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const History(),
                      settings: const RouteSettings(name: "/history"),
                    ));
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                selected: index == 4,
                onTap: () {
                  Navigator.pop(context);
                  if (index != 4) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Settings(),
                      settings: const RouteSettings(name: "/settings"),
                    ));
                  }
                },
              ),
              ListTile(
                leading: ImageIcon(
                  isDark
                    ? const AssetImage('assets/icons/github/github-mark-white.png')
                    : const AssetImage('assets/icons/github/github-mark.png'),
                ),
                title: const Text('Github link'),
                selected: false,
                onTap: () {
                  Navigator.pop(context);
                  launchUrlString("https://github.com/leleleno/viewer_app");
                },
              ),
            ],
          ),
        );
      }
    );
  }
}

class MySearchBar extends ConsumerWidget {
  const MySearchBar({super.key, this.isFocus = false});
  final bool isFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    // 検索ワードを常に監視
    // ignore: unused_local_variable
    final searchWords = ref.watch(searchNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        autofocus: isFocus,
        controller: controller,
        // Dark mode
        style: const TextStyle(
          fontSize: 18,
        ),
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TextFieldのテキストをクリアする
              controller.clear();
              // modalsheet閉じる
              Navigator.of(context).pop();
              // Trigger onSubmitted event manually
              String value = controller.text;
              final notifier = ref.read(searchNotifierProvider.notifier);
              notifier.addData(value);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Search(),
                settings: RouteSettings(name: "/search/$value"),
              ));
            },
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // TextFieldのテキストをクリアする
              controller.clear();
            },
          ),
          hintText: "Search bar",
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (String value) {
          // TextFieldのテキストをクリアする
          controller.clear();
          // modalsheet閉じる
          final notifier = ref.read(searchNotifierProvider.notifier);
          notifier.addData(value);
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const Search(),
            settings: RouteSettings(name: "/search/$value"),
          ));
        },
      ),
    );
  }
}
