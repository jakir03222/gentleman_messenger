import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import 'chat_screen.dart';

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
      name: 'John Doe',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      isOnline: true,
    ),
    User(
      id: '2',
      name: 'Jane Smith',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      isOnline: false,
    ),
    User(
      id: '3',
      name: 'Mike Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      isOnline: true,
    ),
    User(
      id: '4',
      name: 'Sarah Williams',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
      isOnline: false,
    ),
    User(
      id: '5',
      name: 'David Brown',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      isOnline: true,
    ),
    User(
      id: '6',
      name: 'Emily Davis',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
      isOnline: false,
    ),
    User(
      id: '7',
      name: 'Robert Wilson',
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
      isOnline: true,
    ),
    User(
      id: '8',
      name: 'Lisa Anderson',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      isOnline: false,
    ),
    User(
      id: '9',
      name: 'James Taylor',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      isOnline: true,
    ),
    User(
      id: '10',
      name: 'Emma Martinez',
      avatarUrl: 'https://i.pravatar.cc/150?img=10',
      isOnline: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with some default messages
    for (var user in users) {
      _userMessages[user.id] = [
        Message(
          id: '1',
          text: 'Hello! How are you?',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          avatarUrl: user.avatarUrl,
        ),
        Message(
          id: '2',
          text: 'I\'m good, thanks!',
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          avatarUrl: 'https://via.placeholder.com/50',
        ),
      ];
    }
  }

  String _getLastMessageTime(String userId) {
    final messages = _userMessages[userId];
    if (messages == null || messages.isEmpty) return '';
    final lastMessage = messages.last;
    final now = DateTime.now();
    final difference = now.difference(lastMessage.timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final messages = _userMessages[user.id] ?? [];
          final lastMessage = messages.isNotEmpty ? messages.last : null;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  if (user.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(user.name),
              subtitle: Text(
                lastMessage?.text ?? 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getLastMessageTime(user.id),
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (messages.isNotEmpty && !messages.last.isMe)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      user: user,
                      initialMessages: _userMessages[user.id] ?? [],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
