import 'dart:developer';

import 'package:signalr_core/signalr_core.dart';

class SignalRHelperTest {
  final url = 'https://localhost:44349/chatHub';
  HubConnection? hubConnection;

  final List<Map<String, String>> messages = [];

  void connect(receiveMessageHandler) {
    hubConnection = HubConnectionBuilder().withUrl(url).build();
    hubConnection?.onclose((error) => log('Connection Close'));

    hubConnection?.on('ReceiveMessagePrivate', receiveMessageHandler);
    hubConnection?.start();
  }

  void sendMessage({required String receiverConId, required String message}) {
    hubConnection?.invoke('SendPrivateMessage', args: [receiverConId, hubConnection?.connectionId, message]);
  }

  void disconnect() {
    hubConnection?.stop();
  }
}
