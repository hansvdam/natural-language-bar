import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment Request',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
      ),
      home: PaymentRequestScreen3(amount: 55.00, purpose: 'Sinterklaas'),
    );
  }
}

class PaymentRequestScreen3 extends StatelessWidget {
  final double amount;
  final String purpose;

  PaymentRequestScreen3({required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Betaalverzoek'),
        // backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Placeholder(
                fallbackHeight: 100,
                fallbackWidth: double.infinity,
                color: Colors.transparent,
                strokeWidth: 0,
                child: Image(image: AssetImage("assets/images/money.png"))),
          ),
          Text(
            '€${amount.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              // color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            purpose,
            style: TextStyle(
              // color: Colors.white,
              fontSize: 24,
            ),
          ),
          Text(
            '34 dagen geldig',
            style: TextStyle(
              // color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mr John Doe',
            style: TextStyle(
              // color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            'NL89 INGB 4729300',
            style: TextStyle(
              // color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showPopup(context, "Sharing not implemented");
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              });
            },
            child: Text('Deel betaalverzoek'),
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
              onPrimary: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
          TextButton(
            onPressed: () {
              showPopup(context, "QR-code not implemented");
            },
            child: Text(
              'QR-code bewaren of bekijken',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void showPopup(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
