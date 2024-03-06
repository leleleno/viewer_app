import 'package:first_app/pages/uis.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  final String title = "Settings";

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  final int _selectedIndex = 4;

  bool _lights = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, widget.title),
      drawer: myDrawer(context, _selectedIndex),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start ,
          children: <Widget>[
            SwitchListTile(
              title: const Text("Dark mode"),
              value: _lights,
              onChanged: (bool value) {
                setState((){
                  _lights = value;
                });
              },
              subtitle: const Text("Change the status if you like dark mode."),
            ),
            const Text(
              'This is Settings page.',
            ),
          ],
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.favorite),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
