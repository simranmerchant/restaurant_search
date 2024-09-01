import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class NamesNotifier extends StateNotifier<List<String>> {
  NamesNotifier() : super([]);

  List<String> _names = [];

  void loadNames() async {
    try {
      // Load JSON data from assets
      String jsonString = await rootBundle.loadString('assets/restaurants.json');
      List<dynamic> jsonData = jsonDecode(jsonString);

      // Extract names
      _names = jsonData.map((item) => item['name'].toString()).toList();

      // Update the state to reflect the loaded data
      state = _names;
    } catch (e) {
      print("Error loading JSON data: $e");
    }
  }

  void filterNames(String query) {
    if (query.isEmpty) {
      state = _names;
    }
    state = _names
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

final namesProvider = StateNotifierProvider<NamesNotifier, List<String>>((ref) {
  return NamesNotifier();
});

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchScreen(),
    );
  }
}
