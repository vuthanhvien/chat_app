import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketService extends GetxService {
  late IO.Socket socket;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  void connect() {
    socket = IO.io('http://localhost:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });
  }

  void sendMessage(String room, String message) {
    socket.emit('send_message', {'room': room, 'message': message});
  }

  void joinRoom(String room) {
    socket.emit('join_room', room);
  }

  void onMessage(Function(dynamic) callback) {
    socket.on('receive_message', callback);
  }
}
