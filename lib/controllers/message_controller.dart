import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gentleman_messenger/screens/chat_screen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/user.dart';

class MessageController extends GetxController {
  final messages = <Message>[].obs;
  final filteredMessages = <Message>[].obs;
  final searchText = ''.obs;
  final selectedIndex = RxnInt();
  final imageFile = Rx<File?>(null);
  final picker = ImagePicker();
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    ever(searchText, (_) => filterMessages());
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void fetchMessages() {
    messages.value = [
      Message(
        id: const Uuid().v4(),
        text: "Hi, how can I help you?",
        isMe: false,
        avatarUrl: "https://randomuser.me/api/portraits/women/1.jpg",
        timestamp: DateTime.now(),
        name: "Support Team",
      ),
      Message(
        id: const Uuid().v4(),
        text: "I need help with my order",
        isMe: true,
        avatarUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        timestamp: DateTime.now(),
      ),
    ];
    filteredMessages.assignAll(messages);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = Message(
      id: const Uuid().v4(),
      text: text,
      isMe: true,
      avatarUrl: "https://randomuser.me/api/portraits/men/1.jpg",
      timestamp: DateTime.now(),
    );

    messages.add(newMessage);
    _simulateReply();
  }

  void _simulateReply() {
    final typingMessage = Message(
      id: const Uuid().v4(),
      text: "Typing...",
      isMe: false,
      avatarUrl: "https://randomuser.me/api/portraits/women/1.jpg",
      timestamp: DateTime.now(),
    );

    messages.add(typingMessage);

    Future.delayed(const Duration(seconds: 1), () {
      messages.remove(typingMessage);

      final replyMessage = Message(
        id: const Uuid().v4(),
        text: _getSupportReply(messages.last.text),
        isMe: false,
        avatarUrl: "https://randomuser.me/api/portraits/women/1.jpg",
        timestamp: DateTime.now(),
      );

      messages.add(replyMessage);
    });
  }

  String _getSupportReply(String userMessage) {
    if (userMessage.toLowerCase().contains("hello") ||
        userMessage.toLowerCase().contains("hi")) {
      return "Hello! How can I help you today?";
    } else if (userMessage.toLowerCase().contains("order")) {
      return "I'll help you with your order. What's your order number?";
    } else {
      return "Thank you for your message. Our support team will get back to you soon!";
    }
  }

  void selectMessage(int index) {
    if (selectedIndex.value == index) {
      selectedIndex.value = null;
    } else {
      selectedIndex.value = index;
    }
  }

  void updateSearch(String value) {
    searchText.value = value.trim().toLowerCase();
  }

  void filterMessages() {
    if (searchText.isEmpty) {
      filteredMessages.assignAll(messages);
    } else {
      filteredMessages.assignAll(
        messages.where((msg) {
          final searchLower = searchText.value;
          return msg.text.toLowerCase().contains(searchLower) ||
              (msg.name?.toLowerCase().contains(searchLower) ?? false);
        }),
      );
    }
  }

  Future<void> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.photos.request();
    }

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);

      final imageMessage = Message(
        id: const Uuid().v4(),
        text: "Image",
        isMe: true,
        avatarUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        timestamp: DateTime.now(),
      );

      messages.add(imageMessage);
    }
  }

  void showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImageSourceButton(
              context,
              Icons.camera_alt,
              'Camera',
              Colors.blue,
              () => pickImage(ImageSource.camera),
            ),
            _buildImageSourceButton(
              context,
              Icons.photo_library,
              'Gallery',
              Colors.green,
              () => pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final Map<String, List<Message>> _userMessages = {};
  final List<User> users = [
    User(
      id: '1',
      name: "Mike's Auto Service",
      avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      isOnline: true,
    ),
    User(
      id: '2',
      name: 'Brooklyn Simmons',
      avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      isOnline: false,
    ),
    // ...add more users as needed
  ];

  String _search = '';
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    for (var user in users) {
      _userMessages[user.id] = [
        Message(
          id: '1',
          text: "Sorry I'll be late bout 15 min...",
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          avatarUrl: user.avatarUrl,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users
        .where((u) => u.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Persons',
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final messages = _userMessages[user.id] ?? [];
                  final lastMessage =
                      messages.isNotEmpty ? messages.last : null;
                  final isSelected = _selectedUserId == user.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedUserId = user.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            user: user,
                            initialMessages:
                                (_userMessages[user.id] ?? []).cast<Message>(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: isSelected ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isSelected
                            ? BorderSide(color: Colors.orange, width: 1.5)
                            : BorderSide.none,
                      ),
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatarUrl),
                          radius: 26,
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage?.text ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${lastMessage?.timestamp.hour.toString().padLeft(2, '0')}:${lastMessage?.timestamp.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
