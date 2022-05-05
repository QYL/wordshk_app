import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wordshk/search_results_page.dart';

import 'bridge_generated.dart';
import 'constants.dart';
import 'custom_page_route.dart';

enum SearchMode {
  pr,
  variant,
  combined,
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

const base = 'wordshk_api';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);
late final api = WordshkApiImpl(dylib);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSwatch()
        .copyWith(primary: Colors.blue, secondary: Colors.blueAccent);
    const headlineSmall =
        TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold);
    const bodyLarge = TextStyle(fontSize: 28.0);
    const bodyMedium = TextStyle(fontSize: 20.0);
    const bodySmall = TextStyle(fontSize: 18.0);
    var textTheme = const TextTheme(
      headlineSmall: headlineSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    );
    var appBarTheme = AppBarTheme.of(context).copyWith(
      foregroundColor: whiteColor,
      backgroundColor: blueColor,
    );
    const textSelectionTheme = TextSelectionThemeData(
        selectionColor: greyColor,
        selectionHandleColor: greyColor,
        cursorColor: greyColor);
    var textButtonTheme = TextButtonThemeData(
        style: ButtonStyle(
      textStyle:
          MaterialStateProperty.all(bodyLarge.copyWith(color: blueColor)),
      foregroundColor: MaterialStateProperty.resolveWith((_) => blueColor),
    ));
    var elevatedButtonTheme = ElevatedButtonThemeData(
        style: ButtonStyle(
      textStyle:
          MaterialStateProperty.all(bodyLarge.copyWith(color: Colors.white)),
      padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 20.0, horizontal: 35.0)),
    ));
    var lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: blueColor,
      primarySwatch: Colors.blue,
      colorScheme: colorScheme.copyWith(brightness: Brightness.light),
      appBarTheme: appBarTheme,
      textSelectionTheme: textSelectionTheme,
      fontFamily: 'ChironHeiHK',
      textTheme: textTheme,
      iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
      textButtonTheme: textButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
    );
    var darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: blueColor,
      primarySwatch: Colors.blue,
      colorScheme: colorScheme.copyWith(brightness: Brightness.dark),
      appBarTheme: appBarTheme,
      textSelectionTheme: textSelectionTheme,
      fontFamily: 'ChironHeiHK',
      textTheme: textTheme,
      iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
      textButtonTheme: textButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
    );
    return MaterialApp(
      title: 'words.hk',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const MyHomePage(title: 'words.hk home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SearchMode searchMode = SearchMode.combined;

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString("assets/api.json").then((json) {
      api.initApi(json: json);
    });
  }

  @override
  Widget build(BuildContext context) {
    var icon_wide = Image(
        width: MediaQuery.of(context).size.width * 0.7,
        image: const AssetImage('assets/icon_wide.png'));

    return Scaffold(
      appBar: AppBar(title: const Text('words.hk')),
      drawer: SizedBox(
        width: 250,
        child: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "words.hk",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: whiteColor, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                          height: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize! /
                              2),
                      Text(
                        'Crowd-sourced Cantonese dictionary for everyone.',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: whiteColor),
                      )
                    ]),
              ),
              TextButton.icon(
                icon: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.search)),
                label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Dictionary',
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                onPressed: () {
                  // Update the state of the app

                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body:
          // TODO: Show search history
          Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: AppBar().preferredSize.height * 1.5),
          child: Column(
            children: [
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? icon_wide
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        // source: https://www.burkharts.net/apps/blog/over-the-rainbow-colour-filters/
                        // Inverter matrix
                        //R G  B  A  Const
                        -1, 0, 0, 0, 255,
                        0, -1, 0, 0, 255,
                        0, 0, -1, 0, 255,
                        0, 0, 0, 1, 0,
                      ]),
                      child: icon_wide),
              SizedBox(
                  height:
                      Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.5),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                          builder: (context) =>
                              SearchResultsPage(searchMode: searchMode)),
                    );
                  },
                  child: const Text("Search")),
            ],
          ),
        ),
      ),
    );
  }
}
