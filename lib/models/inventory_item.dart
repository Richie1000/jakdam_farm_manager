class InventoryItem {
  String id;
  String name;
  int quantity;
  DateTime dateAdded;

  InventoryItem(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.dateAdded});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  InventoryItem.fromMap(String id, Map<String, dynamic> map)
      : id = id,
        name = map['name'],
        quantity = map['quantity'],
        dateAdded = DateTime.parse(map['dateAdded']);
}
