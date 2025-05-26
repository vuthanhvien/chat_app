import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketService extends GetxService {
  /// Creates a new instance of [SocketService].
  static SocketService get to => Get.find<SocketService>();
  late IO.Socket socket;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  void connect() {
    print('Connecting to socket server...');
    socket = IO.io('http://localhost:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();

    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    // socket.connected;
  }

  sendMessage(String room, String message) {
    socket.emit('send_message', {'room': room, 'message': message});
  }

  joinRoom(String room) {
    socket.emit('join', room);
  }

  onMessage(Function(dynamic) callback) {
    socket.on('message:created', callback);
  }

  onRoomAdd(Function(dynamic) callback) {
    socket.on('room:add', callback);
  }
}
