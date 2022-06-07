import 'package:flutter/material.dart';

import '../models/search_mode.dart';

class SearchModeState with ChangeNotifier {
  SearchMode mode = SearchMode.combined;
  bool showSearchModeSelector = false;

  void updateSearchModeAndCloseSelector(
      SearchMode newMode, FocusNode focusNode) {
    switchKeyboardType(focusNode);
    mode = newMode;
    showSearchModeSelector = false;
    notifyListeners();
  }

  void updateSearchMode(SearchMode newMode, FocusNode focusNode) {
    switchKeyboardType(focusNode);
    mode = newMode;
    notifyListeners();
  }

  void toggleSearchModeSelector() {
    showSearchModeSelector = !showSearchModeSelector;
    notifyListeners();
  }
}

switchKeyboardType(FocusNode focusNode) {
  focusNode.unfocus();
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => focusNode.requestFocus(),
  );
}