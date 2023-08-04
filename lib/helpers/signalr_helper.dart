import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';

class SignalRHelper {
  final url = 'https://localhost:44349/chatHub';
  HubConnection? hubConnection;

  final List<Map<String, String>> messages = [];

  Future<void> initializeConnection(MethodInvocationFunc messageReceivedHandler) async {
    hubConnection = HubConnectionBuilder().withUrl(url).build();
    hubConnection?.onclose((error) => log('Connection Closed'));

    hubConnection?.on('MessageReceived', messageReceivedHandler);
    await hubConnection?.start();
  }

  Future<void> sendMessage(
      {required String receiverConId, required String message}) async {
    if (hubConnection?.state == HubConnectionState.connected) {
      await hubConnection?.invoke('MessageSent',
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
