import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zendesk_flutter_plugin/zendesk_flutter_plugin.dart';
import 'package:zendesk_flutter_plugin/chat_models.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _chatStatus = 'Uninitialized';
  String _zendeskAccountkey = '2a4ijImfXbSkhZAUaUowwsKJZ7248PpL';

  final ZendeskFlutterPlugin _chatApi = ZendeskFlutterPlugin();

  StreamSubscription<ConnectionStatus> _chatConnectivitySubscription;
  StreamSubscription<AccountStatus> _chatAccountSubscription;
  StreamSubscription<List<Agent>> _chatAgentsSubscription;
  StreamSubscription<List<ChatItem>> _chatItemsSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _chatApi.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    _chatConnectivitySubscription = _chatApi.onConnectionStatusChanged.listen(_chatConnectivityUpdated);
    _chatAccountSubscription = _chatApi.onAccountStatusChanged.listen(_chatAccountUpdated);
    _chatAgentsSubscription = _chatApi.onAgentsChanged.listen(_chatAgentsUpdated);
    _chatItemsSubscription = _chatApi.onChatItemsChanged.listen(_chatItemsUpdated);

    String chatStatus;
    try {
      await _chatApi.init(_zendeskAccountkey);
      chatStatus = 'INITIALIZED';
    } on PlatformException {
      chatStatus = 'Failed to initialize.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _chatStatus = chatStatus;
    });
  }

  @override
  void dispose() {
    _chatConnectivitySubscription.cancel();
    _chatAccountSubscription.cancel();
    _chatAgentsSubscription.cancel();
    _chatItemsSubscription.cancel();
    _chatApi.endChat();
    super.dispose();
  }

  void _chatConnectivityUpdated(ConnectionStatus status) {
    print('chatConnectivityUpdated: $status');
  }

  void _chatAccountUpdated(AccountStatus status) {
    print('chatAccountUpdated: $status');
  }

  void _chatAgentsUpdated(List<Agent> agents) {
    print('chatAgentsUpdated: $agents');
  }

  void _chatItemsUpdated(List<ChatItem> chatLog) {
    print('chatItemsUpdated: $chatLog');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('Chat status: $_chatStatus'),
              RaisedButton(
                onPressed: () async {
                  await ZendeskFlutterPlugin().startChat('Test Visitor Name');
                },
                child: Text("Start Chat"),
              ),
              RaisedButton(
                onPressed: () async {
                  await ZendeskFlutterPlugin().getDepartments().then((List<Department> departments) {
                    print(departments);
                  }).catchError((e) {
                    print(e);
                  });
                },
                child: Text("Get Departments"),
              ),
              RaisedButton(
                onPressed: () async {
                  await ZendeskFlutterPlugin().setDepartment('Card');
                },
                child: Text("Set Card Department"),
              ),
              RaisedButton(
                onPressed: () async {
                  await ZendeskFlutterPlugin().sendMessage('Greeting from Visitor');
                },
                child: Text("Send Greeting Message"),
              ),
              RaisedButton(
                onPressed: () async {
                  await ZendeskFlutterPlugin().endChat();
                },
                child: Text("EndChat"),
              ),
            ],
          )
        ),
      ),
    );
  }
}
