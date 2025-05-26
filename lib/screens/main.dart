import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IRoom {
  final String id;
  final String name;

  IRoom({required this.id, required this.name});
}

class IUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? status;
  final DateTime? lastSeen;
  final String? email;
  final String? phoneNumber;

  IUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.status,
    this.lastSeen,
    this.email,
    this.phoneNumber,
  });
}

class IMessage {
  final String id;
  final String content;
  final IUser sender;
  final String roomId;
  final DateTime timestamp;

  IMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.roomId,
    required this.timestamp,
  });
}

enum ListCode {
  user,
  room,
  noti,
  setting,
}

class ChatController extends GetxController {
  static ChatController get to => Get.put(ChatController());

  final rooms = <IRoom>[
    IRoom(id: '1', name: 'General'),
    IRoom(id: '2', name: 'Tech Talk'),
    IRoom(id: '3', name: 'Random'),
  ].obs;
  final room = IRoom(id: '1', name: 'General').obs;

  final users = <IUser>[
    IUser(id: '1', name: 'Alice', avatarUrl: 'https://example.com/alice.jpg'),
    IUser(id: '2', name: 'Bob', avatarUrl: 'https://example.com/bob.jpg'),
    IUser(
        id: '3', name: 'Charlie', avatarUrl: 'https://example.com/charlie.jpg'),
  ].obs;

  void addRoom(String name) {
    final newRoom = IRoom(id: (rooms.length + 1).toString(), name: name);
    rooms.add(newRoom);
    openChat(newRoom);
  }

  void removeRoom(String id) {
    rooms.removeWhere((room) => room.id == id);
  }

  void openChat(IRoom room) {
    this.room.value = room;
  }

  final sreenView = ListCode.user.obs;

  final leftWidth = 300.0.obs;

  final alltabs = <ListCode>[
    ListCode.user,
    ListCode.room,
    ListCode.noti,
    ListCode.setting,
  ];
  final currentTab = ListCode.user.obs;

  final messageList = <IMessage>[].obs;
  List<IMessage> get messages =>
      messageList.where((message) => message.roomId == room.value.id).toList();

  final textController = TextEditingController();

  final newMessage = ''.obs;
  submitMessage(IRoom room, String content) {
    final randomId = DateTime.now().millisecondsSinceEpoch.toString();
    if (content.isNotEmpty) {
      final message = IMessage(
        id: randomId,
        content: content,
        sender: IUser(id: '1', name: 'Alice'),
        roomId: room.id,
        timestamp: DateTime.now(),
      );
      messageList.add(message);
      newMessage.value = '';
      textController.clear();
    }
  }
}

class MainScreen extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          LeftSide(),
          Expanded(
            child: DetailChat(),
          ),
        ],
      ),
    );
  }
}

class LeftSide extends StatelessWidget {
  final ctr = ChatController.to;

  LeftSide({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: ctr.leftWidth.value,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ONLYFANS',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      ctr.sreenView.value = ListCode.room;
                      ctr.addRoom('New Room ${ctr.rooms.length + 1}');
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                switch (ctr.sreenView.value) {
                  case ListCode.user:
                    return UserList();
                  case ListCode.noti:
                    return const Center(child: Text('Notifications'));
                  case ListCode.room:
                    return ListChat();
                  case ListCode.setting:
                    return const Center(child: Text('Settings'));
                }
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ...ctr.alltabs.map(
                    (t) => Expanded(
                      child: InkWell(
                        onTap: () {
                          ctr.sreenView.value = t;
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.face,
                            color: ctr.sreenView.value == t
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class UserList extends StatelessWidget {
  final ctr = ChatController.to;

  UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: ctr.users.length,
        itemBuilder: (context, index) {
          final user = ctr.users[index];
          return InkWell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl ?? ''),
                    radius: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (user.status != null)
                          Text(
                            user.status!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class MessageList extends StatelessWidget {
  MessageList({super.key});
  final ctr = ChatController.to;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: ctr.messages.length,
        itemBuilder: (context, index) {
          final message = ctr.messages[index];
          return ListTile(
            title: Text(message.content),
            subtitle: Text(
              '${message.sender.name} - ${message.timestamp.toLocal()}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(message.sender.avatarUrl ?? ''),
            ),
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final IRoom room;

  ChatScreen({super.key, required this.room});
  final ctr = ChatController.to;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Chat Room: ${room.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: MessageList(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ctr.newMessage.value = value;
                  },
                  controller: ctr.textController,
                  onSubmitted: (value) {
                    ctr.submitMessage(room, value);
                    // Handle send message
                  },
                  onEditingComplete: () {
                    ctr.submitMessage(room, ctr.newMessage.value);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  ctr.submitMessage(room, ctr.newMessage.value);
                  // Handle send message
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DetailChat extends StatelessWidget {
  DetailChat({super.key});
  final ctr = ChatController.to;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (ctr.room.value.id.isNotEmpty) {
          return ChatScreen(room: ctr.room.value);
        }
        return const Center(
          child: Text('Select a chat room to see details'),
        );
      }),
    );
  }
}

class ListChat extends StatelessWidget {
  final ctr = ChatController.to;
  ListChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ctr.rooms.length,
              itemBuilder: (context, index) {
                final room = ctr.rooms[index];
                return Room(room: room);
              },
            ),
          )
        ],
      ),
    );
  }
}

class Room extends StatelessWidget {
  final IRoom room;
  final ctr = ChatController.to;

  Room({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () {
          ChatController.to.openChat(room);
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: ctr.room.value.id == room.id
                ? Colors.blue.withOpacity(0.1)
                : Colors.white,
            // borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name, style: const TextStyle(fontSize: 14)),
                    const Text(
                      'Last message here', // Placeholder for last message
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '10:00 AM', // Placeholder for last message time
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
