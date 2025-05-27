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
