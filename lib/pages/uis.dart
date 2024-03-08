import 'package:first_app/pages/favorite.dart';
import 'package:first_app/pages/history.dart';
import 'package:first_app/pages/search.dart';
import 'package:first_app/pages/settings.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        // search button add
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MySearchBar(isFocus: true),
                    );
                  },
                  // backgroundColor: Colors.transparent,
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary),
              child: const Center(child: Text('Drawer Header')),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('home'),
              selected: index == 0,
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('search'),
              selected: index == 1,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Search(inputText: ""),
                  settings: const RouteSettings(name: "/search"),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('favorite'),
              selected: index == 2,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Favorite(),
                  settings: const RouteSettings(name: "/favorite"),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('history'),
              selected: index == 3,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => History(),
                  settings: const RouteSettings(name: "/history"),
                ));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('settings'),
              selected: index == 4,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Settings(),
                  settings: const RouteSettings(name: "/settings"),
                ));
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

// AppBar myAppbar(BuildContext context, String title) {
//   return AppBar(
//     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//     title: Text(title),
//     // search button add
//     actions: [
//       IconButton(
//           onPressed: () {
//             showModalBottomSheet(
//               context: context,
//               builder: (context) {
//                 return const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: MySearchBar(isFocus: true),
//                 );
//               },
//               // backgroundColor: Colors.transparent,
//             );
//           },
//           icon: const Icon(Icons.search))
//     ],
//   );
// }

// Drawer myDrawer(BuildContext context, int index) {
//   return Drawer(
//     child: ListView(
//       padding: EdgeInsets.zero,
//       children: <Widget>[
//         DrawerHeader(
//           decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.inversePrimary),
//           child: const Center(child: Text('Drawer Header')),
//         ),
//         ListTile(
//           leading: const Icon(Icons.home),
//           title: const Text('home'),
//           selected: index == 0,
//           onTap: () {
//             Navigator.of(context).popUntil((route) => route.isFirst);
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.search),
//           title: const Text('search'),
//           selected: index == 1,
//           onTap: () {
//             Navigator.pop(context);
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => Search(inputText: ""),
//               settings: const RouteSettings(name: "/search"),
//             ));
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.favorite),
//           title: const Text('favorite'),
//           selected: index == 2,
//           onTap: () {
//             Navigator.pop(context);
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => Favorite(),
//               settings: const RouteSettings(name: "/favorite"),
//             ));
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.history),
//           title: const Text('history'),
//           selected: index == 3,
//           onTap: () {
//             Navigator.pop(context);
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => History(),
//               settings: const RouteSettings(name: "/history"),
//             ));
//           },
//         ),
//         const Divider(),
//         ListTile(
//           leading: const Icon(Icons.settings),
//           title: const Text('settings'),
//           selected: index == 4,
//           onTap: () {
//             Navigator.pop(context);
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => Settings(),
//               settings: const RouteSettings(name: "/settings"),
//             ));
//           },
//         ),
//       ],
//     ),
//   );
// }

class MySearchBar extends StatelessWidget {
  MySearchBar({super.key, this.isFocus = false});
  final bool isFocus;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        autofocus: isFocus,
        controller: _controller,
        style: const TextStyle(fontSize: 18, color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TextFieldのテキストをクリアする
              _controller.clear();
              // Trigger onSubmitted event manually
              String value = _controller.text;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Search(
                  inputText: value,
                ),
                settings: RouteSettings(name: "/search/$value"),
              ));
            },
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // TextFieldのテキストをクリアする
              _controller.clear();
            },
          ),
          hintText: "Search bar",
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (String value) {
          // TextFieldのテキストをクリアする
          _controller.clear();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Search(
              inputText: value,
            ),
            settings: RouteSettings(name: "/search/$value"),
          ));
        },
      ),
    );
  }
}
