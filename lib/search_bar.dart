// Copyright (c) 2017, Spencer. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

typedef void TextFieldSubmitCallback(String value);
typedef void TextFieldChangeCallback(String value);
typedef void SetStateCallback(void fn());

enum SearchBarState {
  searching,
  home,
  entry,
}

class SearchBar {
  /// Whether or not the search bar should close on submit. Defaults to true.
  final bool closeOnSubmit;

  /// Whether the text field should be cleared when it is submitted
  final bool clearOnSubmit;

  /// A void callback which takes a string as an argument, this is fired every time the search is submitted. Do what you want with the result.
  final TextFieldSubmitCallback? onSubmitted;

  /// A void callback which gets fired on close button press.
  final VoidCallback? onClosed;

  /// A callback which is fired when clear button is pressed.
  final VoidCallback? onCleared;

  /// Since this should be inside of a State class, just pass setState to this.
  final SetStateCallback setState;

  /// Whether or not the search bar should add a clear input button, defaults to true.
  final bool showClearButton;

  /// What the hintText on the search bar should be. Defaults to 'Search'.
  final String hintText;

  /// Whether search is currently active.
  final ValueNotifier<SearchBarState> searchBarState =
      ValueNotifier(SearchBarState.home);

  /// A callback which is invoked each time the text field's value changes
  final TextFieldChangeCallback? onChanged;

  /// The type of keyboard to use for editing the search bar text. Defaults to 'TextInputType.text'.
  final TextInputType keyboardType;

  /// The controller to be used in the textField.
  late TextEditingController controller;

  /// Whether the clear button should be active (fully colored) or inactive (greyed out)
  bool _clearActive = false;

  SearchBar({
    required this.setState,
    this.onSubmitted,
    TextEditingController? controller,
    this.hintText = 'Search',
    this.closeOnSubmit = true,
    this.clearOnSubmit = true,
    this.showClearButton = true,
    this.onChanged,
    this.onClosed,
    this.onCleared,
    this.keyboardType = TextInputType.text,
  }) {
    this.controller = controller ?? TextEditingController();

    // Don't waste resources on listeners for the text controller if the dev
    // doesn't want a clear button anyways in the search bar
    if (!showClearButton) {
      return;
    }

    this.controller.addListener(() {
      if (this.controller.text.isEmpty) {
        // If clear is already disabled, don't disable it
        if (_clearActive) {
          setState(() {
            _clearActive = false;
          });
        }

        return;
      }

      // If clear is already enabled, don't enable it
      if (!_clearActive) {
        setState(() {
          _clearActive = true;
        });
      }
    });
  }

  /// Initializes the search bar.
  ///
  /// This adds a route that listens for onRemove (and stops the search when that happens), and then calls [setState] to rebuild and start the search.
  void beginSearch(context) {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: () {
      setState(() {
        searchBarState.value = SearchBarState.home;
      });
    }));

    setState(() {
      searchBarState.value = SearchBarState.searching;
    });
  }

  /// Builds the search bar!
  ///
  /// The leading will always be a back button.
  /// backgroundColor is determined by the value of inBar
  /// title is always a [TextField] with the key 'SearchBarTextField', and various text stylings based on [inBar]. This is also where [onSubmitted] has its listener registered.
  ///
  AppBar buildSearchBar(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color? buttonColor = theme.iconTheme.color;

    return AppBar(
      leading: searchBarState.value == SearchBarState.home
          ? null
          : IconButton(
              icon: const BackButtonIcon(),
              color: buttonColor,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                onClosed?.call();
                controller.clear();
                Navigator.maybePop(context);
              }),
      title: searchBarState.value == SearchBarState.entry
          ? null
          : Directionality(
              textDirection: Directionality.of(context),
              child: TextField(
                onTap: () => beginSearch(context),
                style: TextStyle(
                  color: theme.canvasColor,
                ),
                cursorColor: theme.canvasColor,
                key: const Key('SearchBarTextField'),
                keyboardType: keyboardType,
                decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: theme.canvasColor,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none),
                onChanged: onChanged,
                onSubmitted: (String val) async {
                  if (closeOnSubmit) {
                    await Navigator.maybePop(context);
                  }

                  if (clearOnSubmit) {
                    controller.clear();
                  }
                  onSubmitted?.call(val);
                },
                autofocus: true,
                controller: controller,
              ),
            ),
      actions: !showClearButton
          ? null
          : <Widget>[
              // Show an icon if clear is not active, so there's no ripple on tap
              IconButton(
                  icon: const Icon(Icons.clear, semanticLabel: "Clear"),
                  color: buttonColor,
                  disabledColor: theme.disabledColor.withOpacity(0),
                  onPressed: !_clearActive
                      ? null
                      : () {
                          onCleared?.call();
                          controller.clear();
                        }),
            ],
    );
  }

  /// Returns an AppBar based on the value of [isSearching]
  AppBar build(BuildContext context) {
    return buildSearchBar(context);
  }
}
