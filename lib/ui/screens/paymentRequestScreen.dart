import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'PaymentRequestScreen2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Request',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: PaymentRequestScreen(initialAmount: 0.0),
    );
  }
}

class PaymentRequestScreen extends StatefulWidget {
  final double? initialAmount;
  final String? purpose;

  PaymentRequestScreen({Key? key, this.initialAmount, this.purpose})
      : super(key: key);

  @override
  _PaymentRequestScreenState createState() => _PaymentRequestScreenState();
}

class _PaymentRequestScreenState extends State<PaymentRequestScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _amountController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _intialAmount = '';

  @override
  void initState() {
    super.initState();
    var initialAmountAsString =
        widget.initialAmount?.toStringAsFixed(2) ?? '0,00';
    _amountController = TextEditingController(text: initialAmountAsString);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    var intialAmountLength = initialAmountAsString.length ?? 0;
    _animation = Tween<double>(begin: 0, end: intialAmountLength.toDouble())
        .animate(_animationController)
      ..addListener(() {
        final int cursorPosition = _animation.value.round();
        if (cursorPosition <= intialAmountLength) {
          setState(() {
            _intialAmount = initialAmountAsString.substring(0, cursorPosition);
            _amountController.text = _intialAmount;
            _amountController.selection = TextSelection.fromPosition(
                TextPosition(offset: _amountController.text.length));
          });
        }
      });

    if (widget.initialAmount != '0,00') {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nieuw betaalverzoek'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welk bedrag wil je ontvangen?',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Zonder bedrag versturen kan ook',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'EUR',
                suffixText: 'EUR',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Ontvanger kan bedrag aanpassen'),
                  ),
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentRequestScreen2(
                            amount:
                                double.tryParse(_amountController.text) ?? 0.00,
                            purpose: 'Lunch')),
                  );
                },
                child: Text('Verder'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
