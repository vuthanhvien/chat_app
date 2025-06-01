import 'package:chat_app/controllers/main.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageList extends StatelessWidget {
  MessageList({super.key});
  final ctr = ChatController.to;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        reverse: true,
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
            margin: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  if (isSameSender)
                    const SizedBox(width: 40) // Placeholder for alignment
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
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.type == 'image')
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: isMe
                            ? const BoxDecoration(
                                color: Color.fromARGB(255, 31, 162, 228),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                ),
                              )
                            : const BoxDecoration(
                                color: Color.fromARGB(255, 31, 162, 228),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(8.0),
                                ),
                              ),
                        child: Image.network(
                          message.content,
                          // width: 200,
                          height: 200,
                          // fit: BoxFit.cover,
                        ),
                      ),
                    if (message.type == 'text')
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: isMe
                            ? const BoxDecoration(
                                color: Color.fromARGB(255, 31, 162, 228),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                ),
                              )
                            : const BoxDecoration(
                                color: Color.fromARGB(255, 31, 162, 228),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(8.0),
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
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                if (isMe)
                  if (isSameSender)
                    const SizedBox(width: 40) // Placeholder for alignment
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
                    )
              ],
            ),
          );
        },
      ),
    );
  }
}
