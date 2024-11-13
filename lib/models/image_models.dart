import 'package:flutter/material.dart';

class ImageModel extends ChangeNotifier {
  List<String> images = [];
  bool isLoading = false;
  String searchQuery = '';
  int currentPage = 1;
  bool hasMore = true;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void addImages(List<String> newImages) {
    images.addAll(newImages);
    notifyListeners();
  }

  void resetSearch() {
    images = [];
    currentPage = 1;
    hasMore = true;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    resetSearch();
  }

  void nextPage() {
    currentPage++;
  }

  void setHasMore(bool value) {
    hasMore = value;
    notifyListeners();
  }
}
