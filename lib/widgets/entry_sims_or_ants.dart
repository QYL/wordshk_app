import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wordshk/widgets/scalable_text_span.dart';

import '../models/entry.dart';

class EntrySimsOrAnts extends StatelessWidget {
  final String label;
  final List<String> simsOrAnts;
  final TextStyle lineTextStyle;
  final OnTapLink onTapLink;

  const EntrySimsOrAnts(
      {Key? key,
      required this.label,
      required this.simsOrAnts,
      required this.lineTextStyle,
      required this.onTapLink})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Visibility(
      visible: simsOrAnts.isNotEmpty,
      child: Builder(builder: (context) {
        return RichText(
            text: TextSpan(style: lineTextStyle, children: [
          WidgetSpan(
              child: RichText(
                  textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  text: TextSpan(
                      text: label,
                      style: lineTextStyle.copyWith(
                          fontWeight: FontWeight.bold)))),
          const WidgetSpan(child: SizedBox(width: 10)),
          ...simsOrAnts.asMap().entries.map((sim) => TextSpan(children: [
                ScalableTextSpan(context,
                    text: sim.value,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => onTapLink(sim.value)),
                TextSpan(text: sim.key == simsOrAnts.length - 1 ? "" : " · ")
              ]))
        ]));
      }));
}
