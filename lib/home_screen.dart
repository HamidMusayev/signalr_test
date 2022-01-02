import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _userTxt = TextEditingController();
  final TextEditingController _msgTxt = TextEditingController();
  final SignalRHelper _helper = SignalRHelper();

  @override
  void initState() {
    _helper.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _userTxt,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'İstifadəçi adı..',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _msgTxt,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'İsmarıc..',
                  filled: true,
                  prefixIcon: const Icon(Icons.message_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () =>
                        _helper.sendMessage(_userTxt.text, _msgTxt.text),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedCrossFade(
                  firstChild: TextButton.icon(
                    style: TextButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 45),
                        backgroundColor: Colors.redAccent,
                        primary: Colors.white),
                    onPressed: () => _helper.closeConnection(context),
                    label: const Text('Bağlantını kəs'),
                    icon: const Icon(Icons.connect_without_contact_rounded),
                  ),
                  secondChild: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 45)),
                    onPressed: () => _helper.openConnection(context),
                    label: const Text('Bağlantı qur'),
                    icon: const Icon(Icons.connect_without_contact_rounded),
                  ),
                  crossFadeState:
                      _helper.connection.state == HubConnectionState.connected
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 400)),
              const SizedBox(height: 12),
              Container(
                width: 400,
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _helper._messages
                      .map((m) => Text(
                            "User: ${m["user"].toString()} Message: ${m["message"].toString()}",
                            style: const TextStyle(color: Colors.black),
                          )).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // openConnection() async {
  //   final connection = HubConnectionBuilder()
  //       .withUrl(
  //           'https://localhost:44349/chatHub',
  //           HttpConnectionOptions(
  //             client: BrowserClient(),
  //             logging: (level, message) => print(message),
  //           ))
  //       .build();
  //
  //   await connection.start();
  //
  //   connection.on('ReceiveMessage', (message) {
  //     print(message.toString());
  //   });
  //
  //   await connection.invoke('SendMessage', args: ['Bob', 'Says hi!']);
  // }
}

class SignalRHelper extends ChangeNotifier {
  late HubConnection connection;
  final List<Map<String, String>> _messages = [];

  SignalRHelper() {
    connection = HubConnectionBuilder()
        .withUrl('https://localhost:44349/chatHub',
            HttpConnectionOptions(logging: (level, message) => print(message)))
        .build();
  }

  Future<void> openConnection(BuildContext context) async {
    await connection.start();
    if (connection.state == HubConnectionState.connected) notifyListeners();
  }

  Future<void> closeConnection(BuildContext context) async {
    if (connection.state == HubConnectionState.connected) {
      await connection.stop();
      if (connection.state == HubConnectionState.disconnected) {
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage(String user, String message) async {
    await connection.invoke('SendMessage', args: [user, message]);

    _messages.add({"user": user, "message": message});
    notifyListeners();
  }

  Future<void> onMessage() async {
    connection.on("ReceiveMessage", (arguments) {
      //print(arguments);

      _messages.add({
        "user": arguments![0]!.toString(),
        "message": arguments[1].toString()
      });
      notifyListeners();
    });
  }
}
