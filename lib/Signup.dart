import 'package:clario/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'dart:async';
import 'profile.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Country data
  List<Map<String, String>> countries = [
    {'name': 'India', 'code': '+91', 'length': '10'},
    {'name': 'United States', 'code': '+1', 'length': '10'},
    {'name': 'United Kingdom', 'code': '+44', 'length': '10'},
    {'name': 'Australia', 'code': '+61', 'length': '9'},
    {'name': 'Canada', 'code': '+1', 'length': '10'},
  ];
  String selectedCountryCode = '+91';
  String selectedCountryLength = '10';

  // Password visibility toggles
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> registerUser() async {
    final isValidForm = formKey.currentState!.validate();
    if (isValidForm) {
      final username = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('email', email);
      await prefs.setString('phone', '$selectedCountryCode$phone');
      await prefs.setString('password', password);
      await prefs.setBool('isLoggedIn', true);
      await prefs.remove('profileImagePath'); // Clear profile picture for new user

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00BCD4), Color(0xFF009688)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Hero(
                      tag: 'profileHero',
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/clario.jpg'),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Just by filling the form below',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // Name field
                            TextFormField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (name) {
                                if (name == null || name.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Email field
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (email) {
                                if (email == null || email.isEmpty) {
                                  return 'Email is required';
                                } else if (!isValidEmail(email)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Country code dropdown and Phone number field
                            Row(
                              children: [
                                // Country code dropdown styled like a text field
                                Container(
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedCountryCode,
                                      itemHeight: 50,
                                      menuWidth: 220,
                                      items: countries.map((country) {
                                        return DropdownMenuItem<String>(
                                          value: country['code'],
                                          child: Container(
                                            width: 180,
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                            child: Text(
                                              '${country['name']} (${country['code']})',
                                              style: GoogleFonts.poppins(fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCountryCode = value!;
                                          selectedCountryLength = countries
                                              .firstWhere((c) => c['code'] == value)['length']!;
                                        });
                                      },
                                      selectedItemBuilder: (BuildContext context) {
                                        return countries.map<Widget>((country) {
                                          return Center(
                                            child: Text(
                                              country['code']!,
                                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Phone number field
                                Expanded(
                                  child: TextFormField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon: const Icon(Icons.phone),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (phone) {
                                      if (phone == null || phone.isEmpty) {
                                        return 'Please enter a phone number';
                                      } else if (phone.length != int.parse(selectedCountryLength)) {
                                        return 'Enter a valid $selectedCountryLength-digit phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Password field with show/hide option
                            TextFormField(
                              controller: passwordController,
                              obscureText: !passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) => value != null && value.length < 8
                                  ? 'Password must be at least 8 characters'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: !confirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      confirmPasswordVisible = !confirmPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: registerUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyan[700],
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(milliseconds: 100),
                                        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Login Here',
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}