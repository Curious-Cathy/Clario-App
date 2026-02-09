import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment.dart';

class GasSeeMorePage extends StatefulWidget {
  const GasSeeMorePage({super.key});

  @override
  _GasSeeMorePageState createState() => _GasSeeMorePageState();
}

class _GasSeeMorePageState extends State<GasSeeMorePage> {
  final List<Map<String, String>> gasItems = [
    {
      'image': 'assets/HG.png',
      'name': 'HP Gas',
      'description': 'Hindustan Petroleum Gas Services',
    },
    {
      'image': 'assets/RG.png',
      'name': 'Reliance Gas',
      'description': 'Reliance Gas Distribution',
    },
    {
      'image': 'assets/BG.png',
      'name': 'Bharat Gas',
      'description': 'Bharat Petroleum Gas Services',
    },
    {
      'image': 'assets/IG.jpg',
      'name': 'Indian Gas',
      'description': 'Indian Oil Gas Services',
    },
    {
      'image': 'assets/essar.jpeg',
      'name': 'Essar Oil & Gas',
      'description': 'Essar Oil and Gas',
    },
    {
      'image': 'assets/AD.png',
      'name': 'Adani Gas',
      'description': 'Adani Gas',
    },
  ];

  List<Map<String, String>> filteredGasItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredGasItems = gasItems; // Initialize with all items
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredGasItems = gasItems;
      } else {
        filteredGasItems = gasItems.where((item) {
          final name = item['name']!.toLowerCase();
          final queryWords = query.split(' ');
          for (final queryWord in queryWords) {
            if (queryWord.isEmpty) continue;
            final nameWords = name.split(' ');
            if (nameWords.any((word) => word.startsWith(queryWord))) {
              return true;
            }
          }
          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.teal.shade100,
          title: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                Icon(Icons.gas_meter, color: Colors.teal.shade400, size: 20),
                Text(
                  'Gas',
                  style: TextStyle(color: Colors.teal.shade700, fontSize: 20),
                ),
              ],
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.teal),
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Gas Services...',
                        hintStyle: TextStyle(
                          color: Colors.teal.withOpacity(1.0),
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.teal.shade700),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.teal.shade700),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: filteredGasItems.isEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching for terms like "Bharat" or "HP"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  itemCount: filteredGasItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredGasItems[index];
                    return GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final username = prefs.getString('username') ?? 'User';
                        final phoneNumber =
                            prefs.getString('phone') ?? '+91-1234567890';
                        const maskedAccountNumber = 'XXXXXXX5556';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentDetailsPage(
                              serviceName: item['name']!,
                              username: username,
                              accountNumber: maskedAccountNumber,
                              phoneNumber: phoneNumber,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage(item['image']!),
                                backgroundColor: Colors.teal.shade50,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item['description']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}