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
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    _helper.addListener(() => setState(() {}));

    _helper.connect(handler);

    super.initState();
  }

  handler(arguments){
      _messages.add({
        "user": arguments![0]!.toString(),
        "message": arguments[1].toString()
      });
      setState(() {});
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
                    //_helper.sendMessageToUser(_userTxt.text, _helper.connection.connectionId!, _msgTxt.text),
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
                    onPressed: () => _helper.disconnect(),
                    label: const Text('Bağlantını kəs'),
                    icon: const Icon(Icons.connect_without_contact_rounded),
                  ),
                  secondChild: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 45)),
                    onPressed: () => _helper.connect(handler),
                    label: const Text('Bağlantı qur'),
                    icon: const Icon(Icons.connect_without_contact_rounded),
                  ),
                  crossFadeState:
                      _helper.connection?.state == HubConnectionState.connected
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
                  children: _messages
                      .map((m) => Text(
                            "User: ${m["user"].toString()} Message: ${m["message"].toString()}",
                            style: const TextStyle(color: Colors.black),
                          ))
                      .toList(),
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
  HubConnection? connection;
  final String url ='http://192.168.1.5/chatHub';
  //final List<Map<String, String>> _messages = [];

  void connect(receiveMessageHandler) {
    connection = HubConnectionBuilder().withUrl(url).build();
     connection?.onclose((error) {
      print('Connection Closed');
    });
    connection?.on('ReceiveMessage', receiveMessageHandler);
    connection?.start();
    notifyListeners();
  }

  // SignalRHelper() {
  //   connection = HubConnectionBuilder()
  //       .withUrl('http://192.168.1.5/chatHub',
  //       HttpConnectionOptions(logging: (level, message) => print(message)))
  //       .build();
  // }
  // Future<void> openConnection(BuildContext context) async {
  //   await connection.start();
  //   if (connection.state == HubConnectionState.connected) notifyListeners();
  // }

  // Future<void> closeConnection(BuildContext context) async {
  //   if (connection.state == HubConnectionState.connected) {
  //     await connection.stop();
  //     if (connection.state == HubConnectionState.disconnected) {
  //       notifyListeners();
  //     }
  //   }
  // }

  void sendMessage(String user, String message) async {
    if(connection?.state == HubConnectionState.connected){
      connection?.invoke('SendMessage', args: [user, message]);
      //_messages.add({"user": user, "message": message});
      notifyListeners();
    }
    else{
      print('Can not send message while Connection state is: ' + connection!.state.toString());

    }

  }

  void disconnect() {
    connection?.stop();
    //notifyListeners();
  }

  // Future<void> sendMessageToUser(
  //     String user, String connectionId, String message) async {
  //   await connection
  //       .invoke('SendMessageToUser', args: [user, connectionId, message]);
  //
  //   //_messages.add({"user": user, "message": message});
  //   notifyListeners();
  // }

  // Future<void> onMessage() async {
  //   connection.on("ReceiveMessage", (arguments) {
  //     //print(arguments);
  //
  //     _messages.add({
  //       "user": arguments![0]!.toString(),
  //       "message": arguments[1].toString()
  //     });
  //     notifyListeners();
  //   });
  // }
}
