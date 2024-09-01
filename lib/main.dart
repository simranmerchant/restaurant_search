import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _names = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    // Load JSON data from assets
    String jsonString = await rootBundle.loadString('assets/restaurants.json');

    List<dynamic> jsonData = jsonDecode(jsonString);

    // Extract names
    List<String> names = jsonData.map((item) => item['name'].toString()).toList();

    // Update the state to reflect the loaded data
    setState(() {
      _names = names;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Names'),
      ),
      body: _names.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _names.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_names[index]),
                );
              },
            ),
    );
  }
}
