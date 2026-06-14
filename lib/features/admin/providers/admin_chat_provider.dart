import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../core/network/api_service.dart';
import '../../properties/providers/property_provider.dart';
import '../../chat/data/chat_models.dart';

enum AdminChatStatus { initial, loading, loaded, error }

class AdminChatState {
  final AdminChatStatus status;
  final List<Conversation> conversations;
  final String? error;

  AdminChatState({
    this.status = AdminChatStatus.initial,
    this.conversations = const [],
    this.error,
  });

  AdminChatState copyWith({
    AdminChatStatus? status,
    List<Conversation>? conversations,
    String? error,
  }) {
    return AdminChatState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      error: error ?? this.error,
    );
  }
}

class AdminChatNotifier extends StateNotifier<AdminChatState> {
  final ApiService _apiService;
  PusherChannelsFlutter? _pusher;

  AdminChatNotifier(this._apiService) : super(AdminChatState()) {
    _initPusher();
  }

  void _initPusher() {
    _pusher = PusherChannelsFlutter.getInstance();
    // TODO: Configure Pusher with your credentials
    // _pusher.init(
    //   apiKey: 'YOUR_PUSHER_KEY',
    //   cluster: 'YOUR_PUSHER_CLUSTER',
    //   onConnectionStateChange: _onConnectionStateChange,
    //   onSubscriptionSucceeded: _onSubscriptionSucceeded,
    //   onEvent: _onEvent,
    // );
  }

  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    // Handle connection state changes
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    // Handle subscription success
  }

  void _onEvent(PusherEvent event) {
    if (event.eventName == 'App\\Events\\MessageSent') {
      final messageData = event.data;
      final message = Message.fromJson(messageData);
      
      // Update the conversation in the list
      final updatedConversations = state.conversations.map((conversation) {
        if (conversation.id == message.conversationId) {
          return Conversation(
            id: conversation.id,
            userId: conversation.userId,
            userName: conversation.userName,
            userEmail: conversation.userEmail,
            lastMessage: message.body,
            lastMessageTime: message.createdAt,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
          );
        }
        return conversation;
      }).toList();
      
      // Move the updated conversation to the top
      final updatedConversation = updatedConversations.firstWhere(
        (c) => c.id == message.conversationId,
      );
      updatedConversations.remove(updatedConversation);
      updatedConversations.insert(0, updatedConversation);
      
      state = state.copyWith(conversations: updatedConversations);
    }
  }

  Future<void> loadConversations() async {
    state = state.copyWith(status: AdminChatStatus.loading, error: null);
    
    try {
      final response = await _apiService.getAllConversations();
      final conversations = (response as List<dynamic>)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
      
      state = state.copyWith(
        status: AdminChatStatus.loaded,
        conversations: conversations,
      );
      
      // Subscribe to all conversation channels
      for (final conversation in conversations) {
        _subscribeToConversation(conversation.id);
      }
    } catch (e) {
      state = state.copyWith(
        status: AdminChatStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void _subscribeToConversation(int conversationId) {
    if (_pusher == null) return;
    
    final channelName = 'private-conversation.$conversationId';
    // TODO: Subscribe to channel
    // _pusher.subscribe(channelName);
  }

  @override
  void dispose() {
    _pusher?.disconnect();
    super.dispose();
  }
}

// Provider
final adminChatProvider = StateNotifierProvider<AdminChatNotifier, AdminChatState>((ref) {
  return AdminChatNotifier(ref.watch(apiServiceProvider));
});
