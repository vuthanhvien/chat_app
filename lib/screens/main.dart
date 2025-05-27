import 'dart:math';

import 'package:chat_app/api.dart';
import 'package:chat_app/controllers/main.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/socket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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
        color: const Color.fromARGB(255, 37, 35, 35),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ONLYFANS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
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
              ctr.addRoom(
                'user ${user.name}',
                newId: user.id,
              ); // Create a new room with the user
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

          final isMe =
              message.senderId == AuthController.to.currentUser.value.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isMe)
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 31, 162, 228),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        message.content,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                if (isMe)
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
                  )
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
                    Text(
                      room.userRoom.isNotEmpty
                          ? 'Members: ${room.userRoom.length}'
                          : 'No members',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
        Container(
          color: Colors.white,
          width: double.infinity,
          child: Container(
            width: min(Get.width - 300, 900),
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
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            // borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Last message here', // Placeholder for last message
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
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
