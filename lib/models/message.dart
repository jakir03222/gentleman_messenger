import 'package:flutter/material.dart';

class Message {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? imageUrl;
  final String avatarUrl;
  final String? name;

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.avatarUrl,
    this.imageUrl,
    this.name,
  });
}
