import 'dart:io';

class Message {
  final String id;
  final String text;
  final bool isMe;
  final String avatarUrl;
  final DateTime? time;
  final bool isTyping;
  final String? name;
  final String? profileImage;
  final File? imageFile;

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.avatarUrl,
    this.time,
    this.isTyping = false,
    this.name,
    this.profileImage,
    this.imageFile,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isMe,
    String? avatarUrl,
    DateTime? time,
    bool? isTyping,
    String? name,
    String? profileImage,
    File? imageFile,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      time: time ?? this.time,
      isTyping: isTyping ?? this.isTyping,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
