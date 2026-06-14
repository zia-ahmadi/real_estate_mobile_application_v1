import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../chat/data/chat_models.dart';
import '../providers/admin_chat_provider.dart';

class AdminChatInboxScreen extends ConsumerStatefulWidget {
  const AdminChatInboxScreen({super.key});

  @override
  ConsumerState<AdminChatInboxScreen> createState() => _AdminChatInboxScreenState();
}

class _AdminChatInboxScreenState extends ConsumerState<AdminChatInboxScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    await ref.read(adminChatProvider.notifier).loadConversations();
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(adminChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Inbox'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: chatState.status == AdminChatStatus.loading &&
                chatState.conversations.isEmpty
            ? const LoadingWidget()
            : chatState.status == AdminChatStatus.error
                ? AppErrorWidget(
                    message: chatState.error ?? 'Failed to load conversations',
                    onRetry: _loadConversations,
                  )
                : chatState.conversations.isEmpty
                    ? const AppEmptyWidget(
                        message:
                            'When users message you, they will appear here',
                        icon: Icons.chat_bubble_outline,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = chatState.conversations[index];
                          return _ConversationItem(
                            conversation: conversation,
                            time: _formatTime(conversation.lastMessageTime),
                            onTap: () => context.push(
                              '/admin/chat/${conversation.id}?userName=${Uri.encodeComponent(conversation.userName ?? '')}',
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final String time;
  final VoidCallback onTap;

  const _ConversationItem({
    required this.conversation,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  conversation.userName?.isNotEmpty == true
                      ? conversation.userName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.userName ?? 'Unknown User',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          time,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      conversation.userEmail ?? '',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Last message
                    Text(
                      conversation.lastMessage ?? 'No messages yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // TODO: Add unread badge when backend supports it
            ],
          ),
        ),
      ),
    );
  }
}
