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
      print("Error loading JSON data: $e"); // change to logger
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

class SearchScreen extends ConsumerStatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(namesProvider.notifier).loadNames();
  }

  @override
  Widget build(BuildContext context) {
    // rebuild when namesprovider changes 
    final names = ref.watch(namesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) =>
                ref.read(namesProvider.notifier).filterNames(query),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: names.isEmpty
                ? Center(child: Text('No results found'))
                : ListView.builder(
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(names[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
