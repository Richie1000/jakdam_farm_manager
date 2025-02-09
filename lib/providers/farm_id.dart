import 'package:flutter/material.dart';

class FarmIDProvider with ChangeNotifier {
  String? _farmID;

  String? get farmID => _farmID;

  void setFarmID(String farmID) {
    _farmID = farmID;
    notifyListeners(); // Notify listeners when the farm ID changes
  }
}
