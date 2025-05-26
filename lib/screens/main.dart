import 'package:chat_app/api.dart';
import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class IRoom {
  final String id;
  final String name;
  final String description;

  IRoom({required this.id, required this.name, this.description = ''});

  factory IRoom.fromJson(Map<String, dynamic> json) {
    return IRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class IUser {
  String id;
  String name;
  String? avatarUrl;
  String? status;
  DateTime? lastSeen;
  String? email;
  String? phoneNumber;

  IUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.status,
    this.lastSeen,
    this.email,
    this.phoneNumber,
  });

  factory IUser.fromJson(Map<String, dynamic> json) {
    return IUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      status: json['status'] ?? '',
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'status': status,
      'lastSeen': lastSeen?.toIso8601String(),
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}

class IMessage {
  String id;
  String content;
  // IUser sender;
  String senderId;
  String roomId;
  String status; // 'sending', 'sent', 'delivered', 'read'
  DateTime timestamp;

  IMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.roomId,
    required this.timestamp,
    this.status = 'sent',
  });

  String get time => DateTime.now().difference(timestamp).inMinutes < 60
      ? '${DateTime.now().difference(timestamp).inMinutes} minutes ago'
      : '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

  factory IMessage.fromJson(Map<String, dynamic> json) {
    return IMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      // sender: IUser.fromJson(json['sender'] ?? {}),
      senderId: json['senderId'] ?? '',
      status: json['status'] ?? 'sending',
      roomId: json['roomId'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      // 'sender': sender.toJson(),
      'senderId': senderId,
      'status': status,
      'roomId': roomId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ListCode {
  user,
  room,
  noti,
  setting,
}

class ChatController extends GetxController {
  static ChatController get to => Get.put(ChatController());

  final rooms = <IRoom>[].obs;
  final room = IRoom(id: '1', name: 'General').obs;
  final users = <IUser>[].obs;

  void addRoom(String name) {
    API.to.postData('/rooms', {
      'name': name,
      'description': 'This is a new chat room',
    }).then((response) {
      rooms.add(IRoom.fromJson(response));
      openChat(rooms.last);
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to create room: $error');
    });
  }

  void removeRoom(String id) {
    rooms.removeWhere((room) => room.id == id);
  }

  void openChat(IRoom r) {
    room.value = r;
    getMessages();
  }

  final sreenView = ListCode.room.obs;

  final leftWidth = 300.0.obs;

  final alltabs = <ListCode>[
    ListCode.user,
    ListCode.room,
    ListCode.noti,
    ListCode.setting,
  ];

  final messageList = <IMessage>[].obs;
  List<IMessage> get messages =>
      messageList.where((message) => message.roomId == room.value.id).toList();

  final textController = TextEditingController();
  final listMessageCtr = ScrollController();

  final newMessage = ''.obs;
  submitMessage(IRoom room, String content) {
    if (content == '') {
      return;
    }
    print('Submitting message: $content to room: ${room.id}');
    final randomId = const Uuid().v4(); // Generate a random ID for the message
    final message = IMessage(
      id: randomId,
      content: content,
      senderId: AuthController.to.currentUser.value.id,
      roomId: room.id,
      status: 'sending',
      timestamp: DateTime.now(),
    );
    messageList.add(message);
    messageList.refresh();
    // create message
    API.to.postData('/messages', {
      'id': randomId,
      'content': content,
      'roomId': room.id,
      'type': 'text',
      'timestamp': DateTime.now().toIso8601String(),
    }).then((response) {
      for (var m in messageList) {
        if (m.id == message.id) {
          m.status = 'sent'; // Update the status of the sent message
        }
        messageList.refresh();
      }
      // messageList.add(message);
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to send message: $error');
    });

    newMessage.value = '';
    textController.clear();
    // Scroll to the bottom of the message list
    if (listMessageCtr.hasClients) {
      listMessageCtr.animateTo(
        listMessageCtr.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  addUsers() {
    API.to.postData(
      '/rooms/add-user',
      {
        'roomId': room.value.id,
        'userIds': users.map((u) => u.id).toList(),
      },
    ).then((response) {
      print(response);
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to load users: $error');
    });
  }

  getMessages() {
    print('Fetching messages for room: ${room.value.id}');
    API.to.fetchData('/messages?roomId=${room.value.id}').then((response) {
      if (response['data'] is List) {
        messageList.clear();
        for (var m in response['data']) {
          print(m);
          final message = IMessage.fromJson(m);
          messageList.add(message);
        }
        messageList.refresh();
      } else {
        Get.snackbar('Error', 'Invalid response format');
      }
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to load messages: $error');
    });
  }

  getRooms() async {
    try {
      final res = await API.to.fetchData('/rooms');
      if (res['data'] is List) {
        for (var r in res['data']) {
          print(r);
          final room = IRoom.fromJson(r);
          rooms.add(room);
        }
        rooms.refresh();
      } else {
        Get.snackbar('Error', 'Invalid response format');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rooms: $e');
    }
  }

  getUsers() async {
    try {
      final res = await API.to.fetchData('/users');
      if (res['data'] is List) {
        for (var u in res['data']) {
          final user = IUser.fromJson(u);
          users.add(user);
        }
        users.refresh();
      } else {
        Get.snackbar('Error', 'Invalid response format');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    getRooms();
    getUsers();
  }
}

class MainScreen extends StatelessWidget {
  final authCtr = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => authCtr.isLogin.value
              ? Row(
                  children: [
                    LeftSide(),
                    Expanded(
                      child: DetailChat(),
                    ),
                  ],
                )
              : LoginPage(),
        ),
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
                    return Setting();
                }
              }),
            ),
            Container(
              color: Colors.black.withOpacity(0.05),
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
                            t == ListCode.user
                                ? Icons.person
                                : t == ListCode.room
                                    ? Icons.chat
                                    : t == ListCode.noti
                                        ? Icons.notifications
                                        : Icons.settings,
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
            onTap: () {
              ctr.room.value = IRoom(
                id: const Uuid().v4(),
                name: user.name,
                description: 'Chat with ${user.name}',
              );
              ctr.openChat(ctr.room.value);
            },
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
                        if (user.status == 'online')
                          const Text(
                            'Online',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          )
                        else
                          const Text(
                            'Last seen ',
                            style: TextStyle(
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
        controller: ctr.listMessageCtr,
        itemBuilder: (context, index) {
          final message = ctr.messages[index];
          final sender = ctr.users.firstWhere(
            (user) => user.id == message.senderId,
            orElse: () => IUser(id: '', name: 'Unknown'),
          );
          final beforeMessage =
              index > 0 ? ctr.messages[index - 1] : IMessage.fromJson({});
          final isSameSender = beforeMessage.senderId == message.senderId;

          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        message.content,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 31, 162, 228),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                        ),
                      ),
                    ),
                    // Text(
                    //   '${message.time}',
                    //   style: const TextStyle(
                    //     color: Colors.grey,
                    //     fontSize: 12,
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(width: 8),
                if (isSameSender)
                  const SizedBox(width: 40) // Space for the avatar
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${room.name}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      room.description.isNotEmpty
                          ? room.description
                          : 'No description',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  ctr.addUsers();
                  // Handle add member or create new room
                  // ctr.addRoom('New Room ${ctr.rooms.length + 1}');
                },
              ),
            ],
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
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ctr.newMessage.value = value;
                  },
                  controller: ctr.textController,
                  // onSubmitted: (value) {
                  //   ctr.submitMessage(room, value);
                  //   // Handle send message
                  // },
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

class Setting extends StatelessWidget {
  final authCtr = AuthController.to;

  Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Logged in as: ${authCtr.currentUser.value.name}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authCtr.logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
