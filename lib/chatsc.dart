import 'package:flutter/material.dart';

import 'helper.dart';

class ChatScreen extends StatefulWidget {
  final name;

  const ChatScreen({Key? key, required this.name}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var scrollController = ScrollController();
  var txtController = TextEditingController();

  SignalRHelper signalR = SignalRHelper();

  receiveMessageHandler(args) {
    signalR.messages.add({"user": args[0], "message": args[1]});
    scrollController.animateTo(scrollController.position.maxScrollExtent + 75,
        curve: Curves.easeInOutQuart,
        duration: const Duration(milliseconds: 400));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Screen')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              separatorBuilder: (_, i) => const Divider(thickness: 2),
              controller: scrollController,
              itemCount: signalR.messages.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(
                    signalR.messages[i]['user'] == widget.name
                        ? signalR.messages[i]['message'].toString()
                        : '${signalR.messages[i]['user']}: ${signalR.messages[i]['message']}',
                    textAlign: signalR.messages[i]['isMine'] == '1'
                        ? TextAlign.end
                        : TextAlign.start,
                  ),
                );
              },
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: txtController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Send Message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      signalR.sendMessage(widget.name, txtController.text);
                      txtController.clear();
                      scrollController.jumpTo(
                          scrollController.position.maxScrollExtent + 75);
                    },
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
    signalR.connect(receiveMessageHandler);
    super.initState();
  }

  @override
  void dispose() {
    txtController.dispose();
    scrollController.dispose();
    signalR.disconnect();
    super.dispose();
  }
}
