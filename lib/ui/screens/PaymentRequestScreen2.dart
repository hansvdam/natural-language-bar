import 'dart:async';

import 'package:flutter/material.dart';

import 'PaymentRequestScreen3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Request',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: PaymentRequestScreen2(amount: 22.00, purpose: 'Lunch'),
    );
  }
}

class PaymentRequestScreen2 extends StatefulWidget {
  final double amount;
  final String? purpose;

  PaymentRequestScreen2({Key? key, required this.amount, this.purpose})
      : super(key: key);

  @override
  _PaymentRequestScreen2State createState() => _PaymentRequestScreen2State();
}

class _PaymentRequestScreen2State extends State<PaymentRequestScreen2> {
  late TextEditingController _amountController;
  late TextEditingController _purposeController;
  String _typedPupose = '';

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.amount.toStringAsFixed(2));
    _purposeController = TextEditingController(text: widget.purpose);
    _animatePurposeTyping(widget.purpose);
  }

  void _animatePurposeTyping(String? purpose) {
    if (purpose == null) return;
    Timer.periodic(Duration(milliseconds: 150), (Timer timer) {
      if (_typedPupose.length < purpose.length) {
        setState(() {
          _typedPupose = widget.purpose!.substring(0, _typedPupose.length + 1);
          _purposeController.text = _typedPupose;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        // title: Text('Betaalverzoek'),
        // backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nieuw betaalverzoek',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Waar is de €${_amountController.text} voor?',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _purposeController,
              decoration: InputDecoration(
                hintText: 'Purpose of payment',
                counterText: '${_purposeController.text.length}/100',
              ),
              maxLength: 100,
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: <Widget>[
                _buildChip('Sinterklaas'),
                _buildChip('2023'),
                _buildChip('December'),
                _buildChip('Etenje'),
                _buildChip('Cadeau'),
                _buildChip('Boodschappen'),
                _buildChip('Bijdrage'),
                _buildChip('Lunch'),
                _buildChip('Drankjes'),
                _buildChip('Pizza'),
                _buildChip('Kaartje'),
                _buildChip('Vakantie'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentRequestScreen3(
                            amount: double.parse(_amountController.text),
                            purpose: _purposeController.text,
                          )),
                );
                // Handle payment request submission
              },
              child: Text('Nieuw betaalverzoek'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return InkWell(
      onTap: () {
        _purposeController.text = label;
      },
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
