import 'package:flutter/material.dart';
import 'package:signalr_test/helper_test.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrlCnt = ScrollController();
  final TextEditingController _msgTxt = TextEditingController();
  final TextEditingController _userTxt = TextEditingController();

  SignalRHelperTest signalR = SignalRHelperTest();

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
      appBar: AppBar(
          title: SelectableText(
              'My Connection ID - ${signalR.hubConnection?.connectionId}')),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
            child: ListView.separated(
              separatorBuilder: (_, i) => const Divider(thickness: 2),
              controller: _scrlCnt,
              itemCount: signalR.messages.length,
              itemBuilder: (context, i) {
                return ListTile(
                    title: Text(signalR.messages[i]['message'].toString(),
                        textAlign: signalR.messages[i]['isMine'] == '1'
                            ? TextAlign.end
                            : TextAlign.start),
                    subtitle: Text(signalR.messages[i]['user'] ?? ''));
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
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () {
                      signalR.sendMessage(
                          receiverConId: _userTxt.text, message: _msgTxt.text);
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
