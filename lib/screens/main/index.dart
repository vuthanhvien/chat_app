import 'package:chat_app/controllers/main.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/screens/main/left_side.dart';
import 'package:chat_app/screens/main/room_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  final authCtr = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(
          () => authCtr.isLogin.value
              ? Row(
                  children: [
                    LeftSide(),
                    LineResize(),
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

class LineResize extends StatelessWidget {
  final ctr = ChatController.to;

  LineResize({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        ctr.leftWidth.value += details.delta.dx;
        if (ctr.leftWidth.value < 200) {
          ctr.leftWidth.value = 200;
        } else if (ctr.leftWidth.value > Get.width - 300) {
          ctr.leftWidth.value = Get.width - 300;
        }
      },
      behavior: HitTestBehavior.translucent,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: 5,
          color: const Color.fromARGB(255, 50, 50, 50),
        ),
      ),
    );
  }
}
