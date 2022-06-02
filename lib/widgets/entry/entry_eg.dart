import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../bridge_generated.dart' show Script;
import '../../constants.dart';
import '../../models/entry.dart';
import '../../models/entry_language.dart';
import 'entry_line.dart';
import 'entry_rich_line.dart';

class EntryEg extends StatelessWidget {
  final Eg eg;
  final EntryLanguage entryLanguage;
  final Script script;
  final TextStyle lineTextStyle;
  final Color linkColor;
  final double rubyFontSize;
  final OnTapLink onTapLink;
  final FlutterTts player;

  const EntryEg(
      {Key? key,
      required this.eg,
      required this.entryLanguage,
      required this.script,
      required this.lineTextStyle,
      required this.linkColor,
      required this.rubyFontSize,
      required this.onTapLink,
      required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(top: lineTextStyle.fontSize!),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: greyColor,
              width: 2.0,
            ),
          ),
        ),
        padding: EdgeInsets.only(left: lineTextStyle.fontSize! / 1.5),
        child: Column(
          children: [
            // TODO: add tags for chinese vs cantonese
            eg.zho == null
                ? const SizedBox.shrink()
                : EntryRichLine(
                    line: script == Script.Simplified ? eg.zhoSimp! : eg.zho!,
                    lineTextStyle: lineTextStyle,
                    linkColor: linkColor,
                    rubyFontSize: rubyFontSize,
                    onTapLink: onTapLink,
                    player: player,
                  ),
            eg.yue == null
                ? const SizedBox.shrink()
                : EntryRichLine(
                    line: script == Script.Simplified ? eg.yueSimp! : eg.yue!,
                    lineTextStyle: lineTextStyle,
                    linkColor: linkColor,
                    rubyFontSize: rubyFontSize,
                    onTapLink: onTapLink,
                    player: player,
                  ),
            ...(entryLanguage == EntryLanguage.english ||
                        entryLanguage == EntryLanguage.both) &&
                    eg.eng != null
                ? [
                    EntryLine(
                      line: eg.eng!,
                      tag: "",
                      lineTextStyle: lineTextStyle,
                      onTapLink: onTapLink,
                    )
                  ]
                : [],
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ));
}