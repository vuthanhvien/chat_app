class IUserRoom {
  final String userId;
  final String roomId;

  IUserRoom({required this.userId, required this.roomId});

  factory IUserRoom.fromJson(Map<String, dynamic> json) {
    return IUserRoom(
      userId: json['userId'] ?? '',
      roomId: json['roomId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roomId': roomId,
    };
  }
}

class IRoom {
  final String id;
  final String name;
  final String description;
  final String type; // Default type for group chat

  final List<IUserRoom> userRoom;

  IRoom({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.userRoom,
  });

  factory IRoom.fromJson(Map<String, dynamic> json) {
    return IRoom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      userRoom: (json['UserRoom'] ?? [])
              ?.map<IUserRoom>((e) => IUserRoom.fromJson(e))
              .toList() ??
          [],
      type: json['type'] ?? 'group', // Default to 'group' if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'UserRoom': userRoom.map((e) => e.toJson()).toList(),
    };
  }
}

class IUser {
  String id;
  String name;
  String? avatarUrl;
  String? status;
  DateTime? lastSeen;
  String? email;
  String? phoneNumber;

  IUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.status,
    this.lastSeen,
    this.email,
    this.phoneNumber,
  });

  factory IUser.fromJson(Map<String, dynamic> json) {
    return IUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      status: json['status'] ?? '',
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'status': status,
      'lastSeen': lastSeen?.toIso8601String(),
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}

class IMessage {
  String id;
  String content;
  // IUser sender;
  String senderId;
  String roomId;
  String status; // 'sending', 'sent', 'delivered', 'read'
  DateTime timestamp;

  IMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.roomId,
    required this.timestamp,
    this.status = 'sent',
  });

  String get time => DateTime.now().difference(timestamp).inMinutes < 60
      ? '${DateTime.now().difference(timestamp).inMinutes} minutes ago'
      : '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

  factory IMessage.fromJson(Map<String, dynamic> json) {
    return IMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      // sender: IUser.fromJson(json['sender'] ?? {}),
      senderId: json['senderId'] ?? '',
      status: json['status'] ?? 'sending',
      roomId: json['roomId'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      // 'sender': sender.toJson(),
      'senderId': senderId,
      'status': status,
      'roomId': roomId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ListCode {
  user,
  room,
  noti,
  setting,
}
