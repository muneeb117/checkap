import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({Key? key}) : super(key: key);

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  List<Map<String, String>> allItems = [];
  List<Map<String, String>> items = [];
  String _url = 'http://192.168.10.10:5000/clothe-collections';
  TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  String selectedCategory = 'Women';
  List<String> colorOptions = [
    'Blue', 'Black', 'Green', 'Purple', 'White', 'Off White', 'Red', 'Pink',
    'Brown', 'Beige', 'Yellow', 'Golden', 'Maroon', 'Sea Green', 'Olive Green',
    'Navy Blue', 'Dark Blue', 'Multi', 'Grey', 'Peach', 'Orange'
  ];
  String? selectedColor;
  List<String> fabricOptions = [
    'Lawn', 'Organza', 'Cotton', 'Silk', 'Chiffon', 'Velvet', 'Zari',
    'Linen', 'khaddar', 'Polyester', 'Dyed', 'Cambric', 'RawSilk', 'Jamawar',
  ];
  String? selectedFabric;
  List<String> nameOptions = [
    'Kurti', 'Unstitched 2PC', '2-piece', '3PC Stitched', '3PC',
    '2PC Stitched', 'Stitched', 'Shalwar', 'Frock',
  ];
  String? selectedName;

  int itemsPerPage = 50;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'API Data',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              onChanged: (value) {
                filterItemsBySearchQuery();
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showSearchByPreferenceDialog();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Search by Preference',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  Text(
                    'NO SEARCH RESULTS FOUND',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                String imgUrl = item['img']!;
                if (!imgUrl.startsWith('https://')) {
                  imgUrl = 'https:' + imgUrl;
                }

                return ListTile(
                  title: Text(item['title']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Price: ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: item['price'],
                              style: TextStyle(
                                color: Colors.red,
                                backgroundColor: Colors.red.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text("Category: ${item['category']}"),
                      Text("Color: ${item['color']}"),
                      Text("Fabric: ${item['fabric']}"),
                    ],
                  ),
                  leading: Image.network(
                    imgUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  trailing: Text(getBrandNameFromUrl(item['link']!)),
                  onTap: () {
                    _launchUrl(item['link']!);
                  },
                );
              },
            ),
          ),
          Pagination(
            itemCount: allItems.length,
            itemsPerPage: itemsPerPage,
            currentPage: currentPage,
            onChanged: (page) {
              setState(() {
                currentPage = page;
              });
              filterItemsBySearchQuery();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchItems();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  void showSearchByPreferenceDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Search by Preference"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: <String>['Women', 'Men'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                value: selectedColor,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedColor = newValue!;
                  });
                },
                items: colorOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Color',
                  hintText: 'Select color',
                  prefixIcon: Icon(Icons.color_lens),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedFabric,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFabric = newValue!;
                  });
                },
                items: fabricOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Fabric',
                  hintText: 'Select fabric',
                  prefixIcon: Icon(Icons.texture),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedName,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedName = newValue!;
                  });
                },
                items: nameOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Select name',
                  prefixIcon: Icon(Icons.label),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                selectedCategory = 'Women';
                selectedColor = null;
                selectedFabric = null;
                selectedName = null;
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                filterItemsByPreference();
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void filterItemsBySearchQuery() {
    final String searchQuery = _nameController.text.trim().toLowerCase();
    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;
    setState(() {
      items = allItems
          .where((item) {
        final String title = item['title']!.toLowerCase();
        bool nameMatch = selectedName == null ||
            (selectedName == '3PC Unstitched(j. only)' && title.contains('3PC Unstitched')) ||
            title.contains(searchQuery);
        bool colorMatch = selectedColor == null || item['color']!.toLowerCase().contains(selectedColor!);
        bool fabricMatch = selectedFabric == null || item['fabric']!.toLowerCase().contains(selectedFabric!);
        bool categoryMatch = item['category'] == selectedCategory;
        bool brandMatch = item['link']!.contains('junaidjamshed') || item['link']!.contains('generation');
        return nameMatch && colorMatch && fabricMatch && categoryMatch && brandMatch;
      })
          .toList()
          .sublist(startIndex, endIndex);

      // Sort the items in ascending order based on price
      items.sort((a, b) => _parsePrice(a['price'])!.compareTo(_parsePrice(b['price'])!));
    });
  }

  void filterItemsByPreference() {
    final String colorQuery = selectedColor?.toLowerCase() ?? '';
    final String fabricQuery = selectedFabric?.toLowerCase() ?? '';
    final String nameQuery = selectedName?.toLowerCase() ?? '';

    setState(() {
      items = allItems
          .where((item) {
        final String color = item['color']!.toLowerCase();
        final String fabric = item['fabric']!.toLowerCase();
        final String title = item['title']!.toLowerCase();

        bool nameMatch = selectedName == null ||
            (selectedName == '3PC Unstitched(j. only)' && title.contains('3PC Unstitched')) ||
            title.contains(nameQuery);

        bool colorMatch = color.contains(colorQuery) || colorQuery.isEmpty;
        bool fabricMatch = fabric.contains(fabricQuery) || fabricQuery.isEmpty;
        bool categoryMatch = item['category'] == selectedCategory;
        bool brandMatch = item['link']!.contains('junaidjamshed') || item['link']!.contains('generation');
        bool searchMatch = title.contains(_nameController.text.trim().toLowerCase());

        return nameMatch && colorMatch && fabricMatch && categoryMatch && brandMatch && searchMatch;
      })
          .toList();

      // Sort the items in ascending order based on price
      items.sort((a, b) => _parsePrice(a['price'])!.compareTo(_parsePrice(b['price'])!));
    });
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Map<String, String>> fetchedItems = [];
        responseData.forEach((item) {
          fetchedItems.add({
            'title': item['title'],
            'category': item['category'],
            'color': item['color'],
            'fabric': item['fabric'],
            'img': item['img'],
            'price': item['price'],
            'link': item['link'],
          });
        });

        setState(() {
          allItems = fetchedItems;
          filterItemsBySearchQuery();
        });
      } else {
        throw Exception('Error while fetching data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error while fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launch(url)) {
      throw Exception('Could not launch $url');
    }
  }

  String getBrandNameFromUrl(String url) {
    if (url.contains('junaidjamshed')) {
      return 'J.';
    } else if (url.contains('generation')) {
      return 'Generation';
    } else {
      return 'Unknown';
    }
  }

  // Convert the price string to a double
  double? _parsePrice(String? priceString) {
    if (priceString == null) return null;

    // Remove currency symbols and commas
    final cleanedPrice = priceString.replaceAll(RegExp(r'[A-Za-z,. ]'), '');

    // Parse the price as a double
    return double.tryParse(cleanedPrice);
  }
}

class Pagination extends StatelessWidget {
  final int itemCount;
  final int itemsPerPage;
  final int currentPage;
  final void Function(int) onChanged;

  Pagination({
    required this.itemCount,
    required this.itemsPerPage,
    required this.currentPage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int totalPages = (itemCount / itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentPage == 1 ? null : () => onChanged(currentPage - 1),
        ),
        Text('$currentPage / $totalPages'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: currentPage == totalPages ? null : () => onChanged(currentPage + 1),
        ),
      ],
    );
  }
}