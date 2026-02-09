import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment.dart';

class WaterSeeMorePage extends StatefulWidget {
  const WaterSeeMorePage({super.key});

  @override
  _WaterSeeMorePageState createState() => _WaterSeeMorePageState();
}

class _WaterSeeMorePageState extends State<WaterSeeMorePage> {
  final List<Map<String, String>> waterItems = [
    {
      'image': 'assets/Andra.jpeg',
      'name': 'Andhra Pradesh WB',
      'description': 'Andhra Pradesh Water Board',
    },
    {
      'image': 'assets/Ker.jpeg',
      'name': 'Kerala WB',
      'description': 'Kerala Water Authority',
    },
    {
      'image': 'assets/Kar.jpeg',
      'name': 'Karnataka WB',
      'description': 'Karnataka Water Supply',
    },
    {
      'image': 'assets/Maha.jpeg',
      'name': 'Maharashtra WB',
      'description': 'Maharashtra Jeevan Pradhikaran',
    },
    {
      'image': 'assets/goa.jpeg',
      'name': 'Goa WB',
      'description': 'Goa Public Works Department',
    },
    {
      'image': 'assets/haryana.jpeg',
      'name': 'Haryana WB',
      'description': 'Haryana Water Services',
    },
    {
      'image': 'assets/TN.jpeg',
      'name': 'Tamil Nadu WB',
      'description': 'Tamil Nadu Water Board',
    },
    {
      'image': 'assets/delhi.jpeg',
      'name': 'Delhi WB',
      'description': 'Delhi Jal Board',
    },
    {
      'image': 'assets/Guj.png',
      'name': 'Gujarat WB',
      'description': 'Gujarat Water Supply',
    },
  ];

  List<Map<String, String>> filteredWaterItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredWaterItems = waterItems; // Initialize with all items
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
        filteredWaterItems = waterItems;
      } else {
        filteredWaterItems = waterItems.where((item) {
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
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.teal.shade100,
          title: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                Icon(Icons.water_drop, color: Colors.teal.shade400, size: 20),
                Text(
                  'Water',
                  style: TextStyle(fontSize: 20, color: Colors.teal.shade700),
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
                        hintText: 'Search Water Services...',
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
                child: filteredWaterItems.isEmpty
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
                      'Try searching for terms like "Kerala" or "Andhra"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  itemCount: filteredWaterItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredWaterItems[index];
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
                                backgroundColor: Colors.teal[100],
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