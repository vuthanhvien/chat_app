import 'dart:math';

import 'package:chat_app/controllers/main.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/main/message_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomDetail extends StatelessWidget {
  final IRoom room;

  RoomDetail({super.key, required this.room});
  final ctr = ChatController.to;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: const Color.fromARGB(255, 18, 18, 18)),
            ),
          ),
          child: Row(
            children: [
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ctr.isEditTitle.value)
                        Container(
                          height: 30,
                          width: 200,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter room name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              contentPadding: EdgeInsets.all(8.0),
                            ),
                            controller: ctr.titleController,
                            onEditingComplete: () {
                              ctr.isEditTitle.value = false;
                              ctr.updateRoomName(
                                room.id,
                                ctr.titleController.text,
                              );
                            },
                          ),
                        ),
                      if (!ctr.isEditTitle.value)
                        InkWell(
                          onTap: () {
                            ctr.isEditTitle.value = true;
                            ctr.titleController.text = room.name;
                          },
                          child: Text(
                            '${room.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        room.userRoom.isNotEmpty
                            ? 'Members: ${room.userRoom.length}'
                            : 'No members',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  ctr.addUsers();
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
          return RoomDetail(room: ctr.room.value);
        }
        return const Center(
          child: Text('Select a chat room to see details'),
        );
      }),
    );
  }
}
