import 'package:first_app/pages/favorite.dart';
import 'package:first_app/pages/history.dart';
import 'package:first_app/pages/search.dart';
import 'package:first_app/pages/settings.dart';
import 'package:flutter/material.dart';

AppBar myAppbar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              builder: (context) => Search(),
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
  );
}
