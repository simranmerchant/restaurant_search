import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';



class NamesNotifier extends StateNotifier<List<String>> {
  NamesNotifier() : super([]);

  List<String> _names = [];
  Logger logger = Logger();

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
      logger.e('Error loading names: $e');
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
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

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
        centerTitle: true,
        title: const Text('Restaurants'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.purple[50],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple[50]!,
              Colors.purple[400]!,
            ],
          ),  
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (query) =>
                    ref.read(namesProvider.notifier).filterNames(query),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    ),
                ),
              ),
            ),
            Expanded(
              child: names.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: names.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            names[index],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}