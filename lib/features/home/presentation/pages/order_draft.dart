class OrderDraft {
  List<Map<String, dynamic>> items = [];
  Map<String, String> pickupAddress = {};
  Map<String, String> dropoffAddress = {};

  void clear() {
    items.clear();
    pickupAddress = {};
    dropoffAddress = {};
  }
}

final orderDraft = OrderDraft(); // make it globally accessible or via Provider
