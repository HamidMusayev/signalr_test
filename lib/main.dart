import 'package:flutter/material.dart';
import 'package:signalr_test/chatsc.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalR Test',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const ChatScreen(username: 'Hamid'),
    );
  }
}
