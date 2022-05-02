import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'entry.dart';
import 'entry_not_published_page.dart';
import 'main.dart';

class EntryPage extends StatefulWidget {
  int id;

  EntryPage({Key? key, required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  int entryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Entry'),
        ),
        body: FutureBuilder(
          future: api.getEntryGroupJson(id: widget.id).then((json) {
            // log("json is ${json.toString()}");
            var entryGroup = json
                .map((entryJson) => Entry.fromJson(jsonDecode(entryJson)))
                .toList();
            return entryGroup;
          }),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return showEntry(context, snapshot.data, entryIndex, (index) {
                setState(() {
                  entryIndex = index;
                });
              }, (entryVariant) {
                log("Tapped on link $entryVariant");
                api
                    .variantSearch(capacity: 1, query: entryVariant)
                    .then((results) {
                  if (results.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EntryNotPublishedPage(
                              entryVariant: entryVariant)),
                    );
                  } else {
                    log(results[0].variant);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EntryPage(id: results[0].id)),
                    );
                  }
                });
              });
            } else if (snapshot.hasError) {
              log("Entry page failed to load due to an error.");
              log(snapshot.error.toString());
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Entry failed to load."),
              );
            } else {
              // TODO: handle snapshot.hasError and loading screen
              return Container();
            }
          },
        ));
  }
}