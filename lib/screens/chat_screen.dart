import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  User user;
  String messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      user = _auth.currentUser;
    } catch (err) {
      print(err);
    }
  }

  // void getMessages() async {
  //   var messsages = await _fireStore.collection("messages").get();
  //   messsages.docs.forEach((res) {
  //     print(res.data());
  //   });
  // }
  void messagesStream() async {
    await for (var snapshot in _fireStore.collection("messages").snapshots()) {
      for (var res in snapshot.docs) {
        print(res.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // _auth.signOut();
                // Navigator.pop(context);
                messagesStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _fireStore.collection("messages").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                  );
                }
                final messages = snapshot.data.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final Map<String, dynamic> messageMap = message.data();
                  final messageText = messageMap['text'];
                  final messageSender = messageMap['sender'];
                  final messageWidget = Text(
                    '$messageText from $messageSender',
                    style: TextStyle(fontSize: 50.0),
                  );
                  messageWidgets.add(messageWidget);
                }
                return Expanded(
                  child: ListView(children: messageWidgets),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      _fireStore
                          .collection('messages')
                          .add({'text': messageText, 'sender': user.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
