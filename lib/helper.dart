import 'dart:developer';

import 'package:signalr_core/signalr_core.dart';

class SignalRHelper {
  final url = 'http://192.168.1.5/chatHub';
  HubConnection? hubConnection;

  final List<Map<String, String>> messages = [];

  void connect(receiveMessageHandler) {
    hubConnection = HubConnectionBuilder().withUrl(url).build();
    hubConnection?.onclose((error) => log('Connection Close'));

    hubConnection?.on('ReceiveMessage', receiveMessageHandler);
    hubConnection?.start();
  }

  void sendMessage(String username, String message) {
    hubConnection?.invoke('SendMessage', args: [username, message]);
  }

  void disconnect() {
    hubConnection?.stop();
  }
}
