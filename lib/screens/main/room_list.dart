import 'package:chat_app/controllers/main.dart';
import 'package:chat_app/models/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              itemCount: ctr.roomGroup.length,
              itemBuilder: (context, index) {
                final room = ctr.roomGroup[index];
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
                    Text(room.type),
                    Text(
                      room.lastMessageText ??
                          '', // Placeholder for last message
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
