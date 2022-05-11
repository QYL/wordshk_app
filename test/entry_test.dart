import 'dart:convert';

import 'package:test/test.dart';
import 'package:wordshk/entry.dart';

void main() {
  test('simple', () {
    var json = """{
	"id": 56534,
	"variants": [
		{
			"word": "命",
			"prs": "ming6"
		}
	],
	"poses": [
		"語素"
	],
	"labels": [],
	"sims": [],
	"ants": [],
	"defs": [
		{
			"yue": [
				[
					[
						"Link",
						"命"
					],
					[
						"Text",
						"（meng6）嘅讀書音，通常用喺配詞"
					]
				]
			],
			"eng": [
				[
					[
						"Text",
						"life; fate; the literary pronunciation for 命 meng6, usually used in compounds"
					]
				]
			],
			"alts": [],
			"egs": [
				{
					"zho": null,
					"yue": {
						"Ruby": [
							{
								"LinkedWord": [
									[
										[
											[
												"Normal",
												"性"
											]
										],
										[
											"sing3"
										]
									],
									[
										[
											[
												"Bold",
												"命"
											]
										],
										[
											"ming6"
										]
									]
								]
							}
						]
					},
					"eng": [
						[
							"Text",
							"life; lives"
						]
					]
				}
			]
		}
	]
}""";
    var expectedEntry = const Entry(
      id: 56534,
      variants: [Variant("命", "ming6")],
      poses: ["語素"],
      labels: [],
      sims: [],
      ants: [],
      defs: [
        Def(
            yue: Clause([
              Line([
                Segment(SegmentType.link, "命"),
                Segment(SegmentType.text, "（meng6）嘅讀書音，通常用喺配詞")
              ])
            ]),
            eng: Clause([
              Line([
                Segment(SegmentType.text,
                    "life; fate; the literary pronunciation for 命 meng6, usually used in compounds")
              ])
            ]),
            alts: [],
            egs: [
              Eg(
                  zho: null,
                  yue: RichLine(
                      RichLineType.ruby,
                      RubyLine([
                        RubySegment(
                            RubySegmentType.linkedWord,
                            RubySegmentLinkedWord([
                              RubySegmentWord(
                                  EntryWord(
                                      [EntryText(EntryTextStyle.normal, "性")]),
                                  ["sing3"]),
                              RubySegmentWord(
                                  EntryWord(
                                      [EntryText(EntryTextStyle.bold, "命")]),
                                  ["ming6"])
                            ]))
                      ])),
                  eng: Line([Segment(SegmentType.text, "life; lives")]))
            ])
      ],
    );
    expect(Entry.fromJson(jsonDecode(json)), equals(expectedEntry));
  });

  test('Yue eg sentence no prs gloss', () {
    var json = """
    {"id":108744,"variants":[{"word":"呢個","prs":"ni1 go3, li1 go3"},{"word":"哩個","prs":"ni1 go3, li1 go3"}],
    "poses":["代詞"],"labels":[],"sims":[],"ants":[],
    "defs":[
      {"yue":[[["Text","指稱接近自己嘅嘢"]]],
      "eng":[[["Text","this; something close to the speaker"]]],
      "alts":[],
      "egs":[
      {
        "zho":null,
        "yue":{"Text":[["Text",[["Normal","我"]]],["Text",[["Bold","呢"]]]]},
        "eng":[["Text","I think that this person is pretty suspicious."]]
      }
      ]}]}""";
    var expectedEntry = const Entry(
      id: 108744,
      variants: [
        Variant("呢個", "ni1 go3, li1 go3"),
        Variant("哩個", "ni1 go3, li1 go3")
      ],
      poses: ["代詞"],
      labels: [],
      sims: [],
      ants: [],
      defs: [
        Def(
            yue: Clause([
              Line([
                Segment(SegmentType.text, "指稱接近自己嘅嘢"),
              ])
            ]),
            eng: Clause([
              Line([
                Segment(
                    SegmentType.text, "this; something close to the speaker")
              ])
            ]),
            alts: [],
            egs: [
              Eg(
                  zho: null,
                  yue: RichLine(
                      RichLineType.word,
                      WordLine([
                        WordSegment(
                            SegmentType.text,
                            EntryWord([
                              EntryText(EntryTextStyle.normal, "我"),
                            ])),
                        WordSegment(SegmentType.text,
                            EntryWord([EntryText(EntryTextStyle.bold, "呢")]))
                      ])),
                  eng: Line([
                    Segment(SegmentType.text,
                        "I think that this person is pretty suspicious.")
                  ]))
            ])
      ],
    );
    expect(Entry.fromJson(jsonDecode(json)), equals(expectedEntry));
  });
}
