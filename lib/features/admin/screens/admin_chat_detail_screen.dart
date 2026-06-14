import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/chat/data/chat_models.dart';
import '../providers/admin_chat_detail_provider.dart';

class AdminChatDetailScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final String? userName;

  const AdminChatDetailScreen({
    super.key,
    required this.conversationId,
    this.userName,
  });

  @override
  ConsumerState<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends ConsumerState<AdminChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    _currentUserId = authState.user?.id;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    
    final success = await ref
        .read(adminChatDetailProvider(widget.conversationId).notifier)
        .sendMessage(message);
    
    if (!mounted) return;
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      _scrollToBottom();
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    final date = DateTime.parse(dateTime);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  bool _isFromCurrentUser(Message message) {
    return message.senderId == _currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(adminChatDetailProvider(widget.conversationId));
    final authState = ref.watch(authProvider);
    _currentUserId = authState.user?.id;

    // Scroll to bottom when new messages arrive
    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName ?? 'Chat'),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: chatState.status == AdminChatDetailStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : chatState.status == AdminChatDetailStatus.error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              chatState.error ?? 'Failed to load chat',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(adminChatDetailProvider(widget.conversationId).notifier)
                                  .loadConversation(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : chatState.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 80,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: AppTextStyles.h5,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            reverse: true,
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatState.messages[index];
                              final isFromCurrentUser = _isFromCurrentUser(message);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _MessageBubble(
                                  message: message,
                                  isFromCurrentUser: isFromCurrentUser,
                                  time: _formatTime(message.createdAt),
                                ),
                              );
                            },
                          ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFromCurrentUser;
  final String time;

  const _MessageBubble({
    required this.message,
    required this.isFromCurrentUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isFromCurrentUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isFromCurrentUser
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.body,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isFromCurrentUser ? AppColors.background : AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: AppTextStyles.caption.copyWith(
                color: isFromCurrentUser
                    ? AppColors.background.withOpacity(0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
