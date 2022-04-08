import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';

class SignalRHelperTest {
  final url = 'https://localhost:44349/chatHub';
  HubConnection? hubConnection;

  final List<Map<String, String>> messages = [];

  Future<void> connect(receiveMessageHandler) async {
    hubConnection = HubConnectionBuilder().withUrl(url).build();
    hubConnection?.onclose((error) => log('Connection Closed'));

    hubConnection?.on('ReceiveMessagePrivate', receiveMessageHandler);
    await hubConnection?.start();
  }

  Future<void> sendMessage(
      {required String receiverConId, required String message}) async {
    if (hubConnection?.state == HubConnectionState.connected) {
      await hubConnection?.invoke('SendPrivateMessage',
          args: [receiverConId, hubConnection?.connectionId, message]);
    } else {
      debugPrintThrottled(
          'Failed to sent message connection state is: ${hubConnection?.state}');
    }
  }

  Future<void> disconnect() async {
    await hubConnection?.stop();
    hubConnection = null;
  }
}
