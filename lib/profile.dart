import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required Null Function() onProfileImageUpdated});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String username = '';
  String? savedAddress;
  String? phoneNumber;
  String? email;
  bool notificationsEnabled = true;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      _usernameController.text = username;
      savedAddress = prefs.getString('address') ?? '';
      _addressController.text = savedAddress ?? '';
      phoneNumber = prefs.getString('phone') ?? '+91-1234567890';
      _phoneController.text = phoneNumber!;
      email = prefs.getString('email') ?? 'user@example.com';
      _emailController.text = email!;
      notificationsEnabled = prefs.getBool('notifications') ?? true;
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImagePath', image.path);
        setState(() {
          _profileImagePath = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.teal),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.teal),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('address', _addressController.text);
      await prefs.setString('phone', _phoneController.text);
      await prefs.setString('email', _emailController.text);
      setState(() {
        username = _usernameController.text;
        savedAddress = _addressController.text;
        phoneNumber = _phoneController.text;
        email = _emailController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final _passwordFormKey = GlobalKey<FormState>();

    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('password') ?? '';

    // Password visibility states
    bool currentPasswordVisible = false;
    bool newPasswordVisible = false;
    bool confirmPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        currentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          currentPasswordVisible = !currentPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !currentPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    if (value != storedPassword) {
                      return 'Current password is incorrect';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          newPasswordVisible = !newPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !newPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          confirmPasswordVisible = !confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !confirmPasswordVisible,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_passwordFormKey.currentState!.validate()) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('password', passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsAndConditionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Welcome to our app! By using this application, you agree to the following terms and conditions:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                '1. Acceptance of Terms\n'
                    'By accessing or using the app, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                '2. Use of Services\n'
                    'The app allows you to pay bills for various services such as electricity, water, gas, telecom, education, insurance, and broadband. You agree to use these services only for lawful purposes.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                '3. User Responsibilities\n'
                    'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                '4. Payment Processing\n'
                    'All payments made through the app are processed securely. However, we are not responsible for any issues arising from third-party payment gateways.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                '5. Modifications to Terms\n'
                    'We reserve the right to modify these terms at any time. Changes will be effective upon posting within the app.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                '6. Contact Us\n'
                    'For any questions or concerns regarding these Terms and Conditions, please contact our support team at support@example.com.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Colors.teal),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
          ElevatedButton(
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      notificationsEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.cyan.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerDialog,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImagePath != null
                              ? FileImage(File(_profileImagePath!))
                              : const AssetImage('assets/clario.jpg') as ImageProvider,
                          backgroundColor: Colors.white,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Phone: $phoneNumber',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Email: $email',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (savedAddress != null && savedAddress!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Address: $savedAddress',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.teal),
                    title: const Text('Edit Profile'),
                    onTap: _showEditProfileDialog,
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.teal),
                    title: const Text('Change Password'),
                    onTap: _changePassword,
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.teal),
                    title: const Text('Notifications'),
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeColor: Colors.teal,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.question_answer, color: Colors.teal),
                    title: const Text('FAQ'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FAQPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.teal),
                    title: const Text('Terms and Conditions'),
                    onTap: _showTermsAndConditionsDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          color: Colors.teal[100],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.cyan.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: const [
              ExpansionTile(
                title: Text(
                  'How do I pay my bills?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'To pay your bills, go to the Home page, select a category (e.g., Electricity, Water), choose your provider, enter the amount, and click "Pay Now".',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'Can I change my registered phone number?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Yes, you can change your phone number from the Profile page. Tap on "Edit Profile" and update your phone number.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'What happens if my payment fails?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'If your payment fails, you will be notified with an error message. You can retry the payment or contact support for assistance.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'How do I view the Terms and Conditions?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'In the Profile page, tap on "Terms and Conditions" to view the terms in a pop-up dialog.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}