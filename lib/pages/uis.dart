import 'package:first_app/pages/favorite.dart';
import 'package:first_app/pages/history.dart';
import 'package:first_app/pages/search.dart';
import 'package:first_app/pages/settings.dart';
import 'package:flutter/material.dart';

AppBar myAppbar(BuildContext context, String title) {
  return AppBar(
    // TRY THIS: Try changing the color here to a specific color (to
    // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
    // change color while the other colors stay the same.
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    // Here we take the value from the MyHomePage object that was created by
    // the App.build method, and use it to set our appbar title.
    title: Text(title),
  );
}

Drawer myDrawer(BuildContext context, int index) {
  return Drawer(
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
            Navigator.pop(context);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('search'),
          selected: index == 1,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('favorite'),
          selected: index == 2,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoritePage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('history'),
          selected: index == 3,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryPage()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('settings'),
          selected: index == 4,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
      ],
    ),
  );
}

void setState(Null Function() param0) {}
