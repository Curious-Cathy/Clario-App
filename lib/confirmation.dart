import 'dart:math';
import 'dart:ui';
import 'package:clario/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationPage extends StatefulWidget {
  final String serviceName;
  final String amount;

  const ConfirmationPage({super.key, required this.serviceName, required this.amount});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  String username = 'User';
  String accountNumber = 'XXXXXXXXX5556';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      accountNumber = prefs.getString('accountNumber') ?? 'XXXXXXXXX5556';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Receipt',
          style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          color: Colors.teal[100],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.cyan.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: ClipPath(
              clipper: TicketClipper(notchRadius: 10.0, notches: 8), // Custom clipper for ticket shape
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Payment Receipt',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.teal,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Payment Successful!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Service', widget.serviceName, Icons.receipt),
                      _buildDetailRow('Amount Paid', '₹${widget.amount}', Icons.payment),
                      _buildDetailRow('Account Number', accountNumber, Icons.account_balance),
                      _buildDetailRow('Username', username, Icons.person),
                      const SizedBox(height: 16),
                      _buildDashedLine(),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: 120,
                          height: 80,
                          child: CustomPaint(
                            painter: BarcodePainter(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Thank you for your payment!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const Homepage()),
                                  (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Back to Home', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        20,
            (index) => Expanded(
          child: Container(
            height: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: Colors.teal[300],
          ),
        ),
      ),
    );
  }
}

// Custom Clipper for Ticket-like Border
class TicketClipper extends CustomClipper<Path> {
  final double notchRadius;
  final int notches;

  TicketClipper({required this.notchRadius, required this.notches});

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchSize = notchRadius * 2;
    final notchSpacing = size.height / (notches + 1);

    // Start at top-left corner
    path.moveTo(0, 0);

    // Top edge
    path.lineTo(size.width, 0);

    // Right edge with notches
    for (int i = 1; i <= notches; i++) {
      double y = notchSpacing * i;
      path.lineTo(size.width, y - notchRadius);
      path.arcToPoint(
        Offset(size.width, y + notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      );
    }

    // Bottom edge
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    // Left edge with notches
    for (int i = notches; i >= 1; i--) {
      double y = notchSpacing * i;
      path.lineTo(0, y + notchRadius);
      path.arcToPoint(
        Offset(0, y - notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      );
    }

    // Close the path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final random = Random(40);
    double x = 0;
    const minBarWidth = 1.0;
    const maxBarWidth = 6.0;
    const minGap = 1.0;
    const maxGap = 5.0;

    while (x < size.width - maxBarWidth) {
      final barWidth = minBarWidth + random.nextDouble() * (maxBarWidth - minBarWidth);
      final gap = minGap + random.nextDouble() * (maxGap - minGap);

      if (x + barWidth <= size.width) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, barWidth, size.height),
          paint,
        );
      }

      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}