import 'package:flutter/material.dart';
import 'package:signalr_test/screens/chat_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalR Flutter',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        useMaterial3: true,
        //colorSchemeSeed: Colors.green,
      ),
      home: const ChatScreen(),
    );
  }
}
