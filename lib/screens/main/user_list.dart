import 'package:chat_app/controllers/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              final existingRoom = ctr.rooms.firstWhereOrNull((room) =>
                  room.type == 'user' &&
                  room.userRoom.firstWhereOrNull((u) => u.userId == user.id) !=
                      null);
              if (existingRoom != null) {
                ctr.openChat(existingRoom); // Open existing room
              } else {
                // Create a new room if it doesn't exist
                ctr.addRoom(
                  'user ${user.name}',
                  newId: user.id,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl ?? ''),
                    radius: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (user.status == 'online')
                          const Text(
                            'Online',
                            style: TextStyle(color: Colors.green, fontSize: 10),
                          )
                        else
                          const Text(
                            'Last seen ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
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
