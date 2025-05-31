import 'package:chat_app/controllers/main.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/main/room_list.dart';
import 'package:chat_app/screens/main/setting.dart';
import 'package:chat_app/screens/main/user_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                      ctr.addRoom('Nhóm ${ctr.rooms.length + 1}');
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
