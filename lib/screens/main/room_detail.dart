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
            color: Colors.white.withOpacity(0.1),
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
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5.0),
          ),
          margin: const EdgeInsets.all(8.0),
          child: Container(
            width: min(Get.width - 300, 900),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            ctr.newMessage.value = value;
                          },
                          controller: ctr.textController,
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
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.attach_file,
                          size: 14,
                        ),
                        onPressed: () {
                          ctr.attachFile(room);
                          // Handle file attachment
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 14,
                        ),
                        onPressed: () {
                          // Handle camera capture
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.mic,
                          size: 14,
                        ),
                        onPressed: () {
                          // Handle voice message
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 14,
                        ),
                        onPressed: () {
                          // Handle more options
                        },
                      ),
                    ],
                  ),
                )
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
