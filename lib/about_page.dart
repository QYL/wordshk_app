import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'navigation_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    sectionWithImage(String title, String paragraph, String imagePath) =>
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Image.asset(imagePath, fit: BoxFit.fitWidth),
          const SizedBox(
            height: 10,
          ),
          Text(title, style: Theme.of(context).textTheme.titleLarge!),
          Text(paragraph, style: Theme.of(context).textTheme.bodyMedium),
        ]);

    section(String title, TextSpan paragraph) =>
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge!),
          RichText(
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              text: paragraph),
        ]);

    void openLink(String url) async {
      var uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    }

    linkedTextSpan(String text, String link) => TextSpan(
        text: text,
        style: const TextStyle(color: blueColor),
        recognizer: TapGestureRecognizer()..onTap = () => openLink(link));

    return Scaffold(
        appBar: AppBar(title: const Text('About words.hk')),
        drawer: const NavigationDrawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionWithImage(
                  "Introduction",
                  "We use crowd-sourcing methods to sustainably develop a comprehensive Cantonese dictionary that will be useful for both beginners and advanced users. We aim to provide complete explanations and illustrative example sentences.",
                  "assets/images/wordshk_editor_gathering.jpeg",
                ),
                const SizedBox(height: 40),
                sectionWithImage(
                  "Tenets",
                  "Words.hk is a descriptivist dictionary. Our goal is to document the actual contemporary state of the Cantonese language in Hong Kong, not to set an 'authoritative' standard. In addition to usage that is accepted by mainstream Cantonese users, we also document features that are used by a substantial minority.",
                  "assets/images/cantonese_map.png",
                ),
                const SizedBox(height: 40),
                sectionWithImage(
                  "Purpose",
                  "When we started the project, Cantonese dictionaries in Chinese included only words that are not Mandarin; whereas those in English focused on translating simple words and phrases. We believe that making a comprehensive, bilingual Cantonese dictionary would raise the status of Cantonese as a standalone and complete language, helping us pass on our heritage.",
                  "assets/images/old_cantonese_dictionary.jpeg",
                ),
                const SizedBox(height: 40),
                sectionWithImage(
                  "Open Content",
                  "We believe in ideas of open content, and we publish our content under a relatively permissive license. In addition, some of our data that may be useful for developing input methods, natural language processing etc. is released in the Public Domain.",
                  "assets/images/wordshk_open_data.jpeg",
                ),
                const SizedBox(height: 40),
                section(
                    "Want to help?",
                    TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(
                            text:
                                "As long as you use Cantonese in your daily life, no matter where you live, we are more than happy to invite you to our editor team. If you are interested in joining us, please contact us via either ",
                          ),
                          linkedTextSpan("email", "mailto:join@words.hk"),
                          const TextSpan(text: " or "),
                          linkedTextSpan("Facebook",
                              "https://www.facebook.com/www.words.hk")
                        ])),
              ],
            ),
          ),
        ));
  }
}
