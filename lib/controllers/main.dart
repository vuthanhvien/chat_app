import 'package:chat_app/api.dart';
import 'package:chat_app/models/types.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/socket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.put(ChatController());

  final rooms = <IRoom>[].obs;
  List<IRoom> get roomLists => rooms.where((e) => e.type == 'group').toList();
  final room = IRoom.fromJson({}).obs; // Initialize with an empty room
  final users = <IUser>[].obs;

  void addRoom(String name, {String? newId}) {
    API.to.postData('/rooms', {
      'name': name,
      'description': 'This is a new chat room',
      'userId': newId
    }).then((response) {
      // rooms.add(IRoom.fromJson(response));
      // openChat(rooms.last);
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
    API.to
        .postData(
          '/rooms/add-user',
          {
            'roomId': room.value.id,
            'userIds': users.map((u) => u.id).toList(),
          },
        )
        .then((response) {})
        .catchError((error) {
          Get.snackbar('Error', 'Failed to load users: $error');
        });
  }

  getMessages() {
    API.to.fetchData('/messages?roomId=${room.value.id}').then((response) {
      if (response['data'] is List) {
        messageList.clear();
        for (var m in response['data']) {
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
        rooms.clear();
        for (var r in res['data']) {
          final room = IRoom.fromJson(r);
          rooms.add(room);
        }
        rooms.refresh();

        for (var room in rooms) {
          SocketService.to.joinRoom(room.id);
        }
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

    SocketService.to.onMessage((data) {
      final message = IMessage.fromJson(data);
      var isExits = false;
      for (var m in messageList) {
        if (m.id == message.id) {
          isExits = true; // Message already exists, update it
          m.status = 'sent'; // Update the status of the sent message
        }
        messageList.refresh();
      }
      if (!isExits) {
        messageList.add(message);
      }
    });

    SocketService.to.onRoomAdd((data) {
      final room = IRoom.fromJson(data);
      final index = rooms.indexWhere((r) => r.id == room.id);
      if (index != -1) {
        rooms[index] = room; // Update existing room
      } else {
        rooms.add(room); // Add new room
      }
      rooms.refresh();
      // openChat(room); // Automatically open the new room
    });
  }

  // void listenToWidthChanges() {
  //   Get.width.listen((width) {
  //     if (width < 600) {
  //       leftWidth.value = 0; // Hide left side on small screens
  //     } else {
  //       leftWidth.value = 300; // Show left side on larger screens
  //     }
  //   });
  // }
}
