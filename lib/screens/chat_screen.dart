import 'package:flutter/material.dart';

import 'package:signalr_test/widgets/chat_bubble.dart';
import 'package:signalr_test/helpers/signalr_helper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageText = TextEditingController();
  final TextEditingController _userTxt = TextEditingController();

  SignalRHelper signalR = SignalRHelper();

  void messageReceivedHandler(args) {
    signalR.messages.add({"user": args[0], "message": args[1]});
    scrollToEnd();
    setState(() {});
  }

  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 75,
      curve: Curves.easeInOutQuart,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future sendMessage() async {
    await signalR.sendMessage(
        receiverConId: _userTxt.text, message: _messageText.text);

    _messageText.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectableText(
          'My Connection Id - ${signalR.hubConnection?.connectionId}',
        ),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _userTxt,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Connection ID',
                  suffixIcon: Icon(Icons.format_indent_decrease_rounded),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.separated(
                separatorBuilder: (context, i) => const SizedBox(height: 6),
                controller: _scrollController,
                itemCount: signalR.messages.length,
                itemBuilder: (context, i) => signalR.messages[i]['user'] ==
                        signalR.hubConnection?.connectionId
                    ? ChatBubble.right(message: signalR.messages[i])
                    : ChatBubble.left(message: signalR.messages[i]),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _messageText,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Send Message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () async =>
                        _messageText.text.isNotEmpty ? await sendMessage() : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    setupConnection().then((value) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    disposeConnection();
    super.dispose();
  }

  Future setupConnection() async {
    await signalR.initializeConnection(messageReceivedHandler);
  }

  Future disposeConnection() async {
    _messageText.dispose();
    _scrollController.dispose();
    await signalR.disconnect();
  }
}
