import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'water.dart';
import 'gas.dart';
import 'telecom.dart';
import 'electricity.dart';
import 'edu.dart';
import 'insurance.dart';
import 'broadband.dart';
import 'profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String username = '';
  int _selectedIndex = 0;
  String currentTime = '';
  String searchQuery = '';
  String? _profileImagePath;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.electric_bolt,
      'name': 'Electricity',
      'page': const ElectricitySeeMorePage(),
    },
    {
      'icon': Icons.water_drop_outlined,
      'name': 'Water',
      'page': const WaterSeeMorePage(),
    },
    {
      'icon': Icons.gas_meter,
      'name': 'Gas',
      'page': const GasSeeMorePage(),
    },
    {
      'icon': Icons.phone_android,
      'name': 'Telecom',
      'page': const TelecomSeeMorePage(),
    },
    {
      'icon': Icons.school,
      'name': 'Education',
      'page': const EducationSeeMorePage(),
    },
    {
      'icon': Icons.security,
      'name': 'Insurance',
      'page': const InsuranceSeeMorePage(),
    },
    {
      'icon': Icons.wifi,
      'name': 'Broadband',
      'page': const BroadbandSeeMorePage(),
    },
  ];

  final Map<String, List<Map<String, String>>> sectionItems = {
    'Water': [
      {'image': 'assets/Andra.jpeg', 'name': 'Andhra Pradesh'},
      {'image': 'assets/Ker.jpeg', 'name': 'Kerala'},
      {'image': 'assets/Kar.jpeg', 'name': 'Tamil Nadu'},
      {'image': 'assets/Maha.jpeg', 'name': 'Maharashtra'},
      {'image': 'assets/Guj.png', 'name': 'Gujarat'},
    ],
    'Electricity': [
      {'image': 'assets/KE.png', 'name': 'Karnataka'},
      {'image': 'assets/GOE.jpeg', 'name': 'Goa'},
      {'image': 'assets/ME.png', 'name': 'Maharashtra'},
      {'image': 'assets/HE.png', 'name': 'Haryana'},
      {'image': 'assets/PE.jpeg', 'name': 'Punjab'},
    ],
    'Gas': [
      {'image': 'assets/HG.png', 'name': 'HP Gas'},
      {'image': 'assets/RG.png', 'name': 'Reliance Gas'},
      {'image': 'assets/BG.png', 'name': 'Bharat Gas'},
      {'image': 'assets/IG.jpg', 'name': 'Indian Gas'},
      {'image': 'assets/essar.jpeg', 'name': 'Esser Oil & Gas'},
    ],
    'Telecom': [
      {'image': 'assets/vi.png', 'name': 'Vodafone Idea'},
      {'image': 'assets/airtel.png', 'name': 'Airtel'},
      {'image': 'assets/bsnl.png', 'name': 'BSNL'},
      {'image': 'assets/jio.jpg', 'name': 'Jio'},
      {'image': 'assets/MTNL.jpg', 'name': 'MTNL'},
    ],
    'Education': [
      {'image': 'assets/cbse.png', 'name': 'CBSE'},
      {'image': 'assets/scert.png', 'name': 'SCERT Ker'},
      {'image': 'assets/icse.jpg', 'name': 'ICSE'},
      {'image': 'assets/scert tamil.jpg', 'name': 'SCERT TN'},
      {'image': 'assets/scert maha.png', 'name': 'SCERT M'},
    ],
    'Insurance': [
      {'image': 'assets/lic.png', 'name': 'LIC India'},
      {'image': 'assets/hdfc.png', 'name': 'HDFC Life'},
      {'image': 'assets/sbi.jpg', 'name': 'SBI Life'},
      {'image': 'assets/icici.png', 'name': 'ICICI Prudential'},
      {'image': 'assets/bajaj.jpg', 'name': 'Bajaj Allianz'},
    ],
    'Broadband': [
      {'image': 'assets/jio.jpg', 'name': 'Jio Fiber'},
      {'image': 'assets/airtel.png', 'name': 'Airtel Xstream'},
      {'image': 'assets/bsnl.png', 'name': 'BSNL Broadband'},
      {'image': 'assets/act.png', 'name': 'ACT Fibernet'},
      {'image': 'assets/excitel.png', 'name': 'Excitel Broadband'},
      {'image': 'assets/kv.jpg', 'name': 'Kerala Vision Broadband'},
    ],
  };

  @override
  void initState() {
    super.initState();
    loadUsername();
    loadProfileImage();
    updateTime();
    Timer.periodic(const Duration(minutes: 1), (timer) => updateTime());
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  void updateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = searchQuery.isEmpty
        ? categories
        : categories
        .where((category) => category['name']
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade100, Colors.cyan.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              _selectedIndex == 0
                  ? ListView(
                padding: const EdgeInsets.only(top: 40),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade400,
                              Colors.cyan.shade300,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Hero(
                                      tag: 'avatar',
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: _profileImagePath !=
                                            null
                                            ? FileImage(
                                            File(_profileImagePath!))
                                            : const AssetImage(
                                            'assets/clario.jpg')
                                        as ImageProvider,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello, $username!',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currentTime,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
                            controller: _searchController,
                            style: const TextStyle(color: Colors.teal),
                            decoration: InputDecoration(
                              hintText: 'Search categories...',
                              hintStyle: TextStyle(
                                color: Colors.teal.withOpacity(1.0),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.teal.shade400,
                              ),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.teal.shade400,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: filteredCategories.isEmpty
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
                          'Try searching for terms like "Electricity", "Water", or "Broadband"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                        : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          filteredCategories.length,
                              (index) {
                            final category = filteredCategories[index];
                            return Padding(
                              padding:
                              const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      category['page'],
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.teal
                                                .withOpacity(0.2),
                                            blurRadius: 8,
                                            offset:
                                            const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        category['icon'],
                                        color: Colors.teal.shade400,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      category['name']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.teal.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Always display all sections, regardless of search query
                  ...categories.map((category) {
                    if (sectionItems.containsKey(category['name'])) {
                      return buildSection(
                        category['name'],
                        category['page'],
                        sectionItems[category['name']]!,
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ],
              )
                  : ProfilePage(
                onProfileImageUpdated: () {
                  loadProfileImage(); // Refresh image on Homepage
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal.shade400,
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget categoryItem(IconData icon, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Column(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.teal.shade400, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.teal.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(
      String title, Widget seeMorePage, List<Map<String, String>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.teal.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => seeMorePage),
                              );
                            },
                            child: Column(
                              children: [
                                Hero(
                                  tag: 'item-$title-$index',
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage: AssetImage(item['image']!),
                                    backgroundColor: Colors.teal.shade50,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['name']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.teal.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => seeMorePage),
                      );
                    },
                    child: Column(
                      children: [
                        Hero(
                          tag: 'see-more-$title',
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.teal.shade50,
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.teal.shade400,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'See More',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.teal.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}