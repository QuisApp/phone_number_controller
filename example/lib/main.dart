import 'package:flutter/material.dart';
import 'package:phone_number_controller/phone_number_controller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PhoneNumberController example',
      home: PhoneNumberControllerPage(),
    );
  }
}

class PhoneNumberControllerPage extends StatefulWidget {
  const PhoneNumberControllerPage({super.key});

  @override
  PhoneNumberControllerPageState createState() =>
      PhoneNumberControllerPageState();
}

class PhoneNumberControllerPageState extends State<PhoneNumberControllerPage> {
  final _controller = PhoneNumberController(countryCode: 'us');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PhoneNumberController example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: 'Enter phone number',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}
