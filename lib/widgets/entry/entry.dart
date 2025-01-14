import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wordshk/utils.dart';

import '../../models/entry.dart';
import '../../states/player_state.dart';
import 'entry_tab.dart';

class EntryWidget extends StatefulWidget {
  final List<Entry> entryGroup;
  final int initialEntryIndex;
  final int? initialDefIndex;
  final OnTapLink onTapLink;

  const EntryWidget({
    Key? key,
    required this.entryGroup,
    required this.initialEntryIndex,
    required this.initialDefIndex,
    required this.onTapLink,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget> {
  int? entryIndex;

  @override
  Widget build(BuildContext context) {
    double rubyFontSize = Theme.of(context).textTheme.headlineSmall!.fontSize!;
    TextStyle lineTextStyle = Theme.of(context).textTheme.bodyMedium!;
    final localizationContext = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DefaultTabController(
        length: widget.entryGroup.length,
        initialIndex: entryIndex ?? widget.initialEntryIndex,
        child: Expanded(
          child: Column(children: [
            Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  onTap: (newIndex) {
                    if (newIndex != entryIndex) {
                      context.read<PlayerState>().stop();
                      setState(() {
                        entryIndex = newIndex;
                      });
                    }
                  },
                  isScrollable: true,
                  // Required
                  labelColor: lineTextStyle.color,
                  unselectedLabelColor: lineTextStyle.color,
                  // Other tabs color
                  labelPadding: const EdgeInsets.symmetric(horizontal: 30),
                  // Space between tabs
                  indicator: UnderlineTabIndicator(
                    borderSide:
                        BorderSide(color: lineTextStyle.color!, width: 2),
                    // Indicator height
                    insets: const EdgeInsets.symmetric(
                        horizontal: 30), // Indicator width
                  ),
                  tabs: widget.entryGroup
                      .asMap()
                      .entries
                      .map((entry) => Tab(
                          text: (entry.key + 1).toString() +
                              " " +
                              entry.value.poses
                                  .map((pos) =>
                                      translatePos(pos, localizationContext))
                                  .join("/")))
                      .toList(),
                )),
            Expanded(
              child: IndexedStack(
                  index: entryIndex ?? widget.initialEntryIndex,
                  sizing: StackFit.expand,
                  children: widget.entryGroup
                      .mapIndexed((index, entry) => EntryTab(
                            entry: entry,
                            script: getScript(context),
                            variantTextStyle:
                                Theme.of(context).textTheme.headlineSmall!,
                            prTextStyle: Theme.of(context).textTheme.bodySmall!,
                            lineTextStyle: lineTextStyle,
                            linkColor: Theme.of(context).colorScheme.secondary,
                            rubyFontSize: rubyFontSize,
                            onTapLink: widget.onTapLink,
                            initialDefIndex: index == widget.initialEntryIndex
                                ? widget.initialDefIndex
                                : null,
                          ))
                      .toList()),
            ),
          ]),
        ),
      ),
    ]);
  }
}
