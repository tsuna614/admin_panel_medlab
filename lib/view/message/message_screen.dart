import 'dart:convert';

import 'package:admin_panel_medlab/data/global_data.dart';
import 'package:admin_panel_medlab/models/message_model.dart';
import 'package:admin_panel_medlab/view/message/message_bubble.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.userId});

  final String userId;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // Connect to WebSocket server
  late WebSocketChannel channel;

  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<int> _notifier = ValueNotifier(-1);
  final _scrollController = ScrollController();
  List<MessageItem> messages = [];

  Future<void> fetchAllMessages() async {
    final dio = Dio();
    final Response response = await dio.get(
      '${GlobalData.baseUrl}/messages/fetchMessages/${widget.userId}',
      // queryParameters: {'id': getConversationId()},
    );

    if (response.statusCode == 200) {
      print('Messages fetched successfully: ${response.data}');
      final List<dynamic> data = response.data["adminMessage"];
      setState(() {
        messages.addAll(data.map((e) => MessageItem.fromJson(e)));
        scrollToBottom();
      });
    } else {
      throw Exception('Failed to load messages');
    }
  }

  void sendMessage(String value) {
    final newMessage = MessageItem(
      message: value,
      senderType: "admin",
      userId: widget.userId,
    );
    channel.sink.add(json.encode(newMessage.toJson()));
    _textController.clear();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();

    channel = WebSocketChannel.connect(
      Uri.parse(
        GlobalData.socketUrl,
      ).replace(queryParameters: {"id": widget.userId, "isAdmin": "true"}),
    );

    fetchAllMessages();
  }

  @override
  void dispose() {
    channel.sink.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Display messages
          messages.isEmpty
              ? Expanded(child: const Center(child: Text('No messages found')))
              : Expanded(
                  child: StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        messages.add(
                          MessageItem.fromJson(
                            json.decode(snapshot.data.toString()),
                          ),
                        );
                        // messages.add(MessageItem.fromJson(snapshot.data)); // This line will throw an error

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      }

                      return ValueListenableBuilder(
                        valueListenable: _notifier,
                        builder: (context, value, child) {
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (_notifier.value == index) {
                                    _notifier.value = -1;
                                  } else {
                                    _notifier.value = index;
                                  }
                                },
                                child: MessageBubble(
                                  message: messages[index].message,
                                  isCurrentUser:
                                      messages[index].senderType == "admin",
                                  isChosenMessage: _notifier.value == index,
                                  createdTime:
                                      messages[index].createdAt ??
                                      DateTime.now(),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Send a message'),
              onSubmitted: (value) {
                sendMessage(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
