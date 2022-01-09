import 'package:flutter/material.dart';

import 'helper.dart';

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrlCnt = ScrollController();
  final TextEditingController _msgTxt = TextEditingController();

  SignalRHelper signalR = SignalRHelper();

  receiveMessageHandler(args) {
    signalR.messages.add({"user": args[0], "message": args[1]});
    _scrlCnt.animateTo(_scrlCnt.position.maxScrollExtent + 75,
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
              controller: _scrlCnt,
              itemCount: signalR.messages.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(
                    signalR.messages[i]['user'] == widget.username
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
                controller: _msgTxt,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Send Message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      signalR.sendMessage(widget.username, _msgTxt.text);
                      //signalR.sendMessageToUser(widget.username, signalR.hubConnection!.connectionId!, _msgTxt.text);
                      _msgTxt.clear();
                      _scrlCnt.jumpTo(_scrlCnt.position.maxScrollExtent + 75);
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
    _msgTxt.dispose();
    _scrlCnt.dispose();
    signalR.disconnect();
    super.dispose();
  }
}
