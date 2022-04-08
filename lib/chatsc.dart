import 'package:flutter/material.dart';
import 'package:signalr_test/bubble/left.dart';
import 'package:signalr_test/bubble/right.dart';
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
    _scrlCnt.animateTo(
      _scrlCnt.position.maxScrollExtent + 75,
      curve: Curves.easeInOutQuart,
      duration: const Duration(milliseconds: 400),
    );
    setState(() {});
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
                controller: _scrlCnt,
                itemCount: signalR.messages.length,
                itemBuilder: (context, i) => signalR.messages[i]['user'] ==
                        signalR.hubConnection?.connectionId
                    ? RightBubble(message: signalR.messages[i])
                    : LeftBubble(message: signalR.messages[i]),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _msgTxt,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Send Message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () async {
                      if (_msgTxt.text.isNotEmpty) {
                        await signalR.sendMessage(
                            receiverConId: _userTxt.text,
                            message: _msgTxt.text);
                        _msgTxt.clear();
                      }
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
    setupConnection().then((value) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    disposeConnection();
    super.dispose();
  }

  Future<void> setupConnection() async {
    await signalR.connect(receiveMessageHandler);
  }

  Future<void> disposeConnection() async {
    _msgTxt.dispose();
    _scrlCnt.dispose();
    await signalR.disconnect();
  }
}
