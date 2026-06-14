import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../core/network/api_service.dart';
import '../../properties/providers/property_provider.dart';
import '../../chat/data/chat_models.dart';

enum AdminChatDetailStatus { initial, loading, loaded, error }

class AdminChatDetailState {
  final AdminChatDetailStatus status;
  final Conversation? conversation;
  final List<Message> messages;
  final String? error;

  AdminChatDetailState({
    this.status = AdminChatDetailStatus.initial,
    this.conversation,
    this.messages = const [],
    this.error,
  });

  AdminChatDetailState copyWith({
    AdminChatDetailStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    String? error,
  }) {
    return AdminChatDetailState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

class AdminChatDetailNotifier extends StateNotifier<AdminChatDetailState> {
  final ApiService _apiService;
  final int conversationId;
  PusherChannelsFlutter? _pusher;

  AdminChatDetailNotifier(this._apiService, this.conversationId) : super(AdminChatDetailState()) {
    _initPusher();
    loadConversation();
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
      
      // Add message to list if it belongs to current conversation
      if (message.conversationId == conversationId) {
        state = state.copyWith(
          messages: [...state.messages, message],
        );
      }
    }
  }

  Future<void> loadConversation() async {
    state = state.copyWith(status: AdminChatDetailStatus.loading, error: null);
    
    try {
      // First load messages
      await loadMessages();
      
      // Subscribe to Pusher channel
      _subscribeToConversation();
    } catch (e) {
      state = state.copyWith(
        status: AdminChatDetailStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMessages() async {
    try {
      final response = await _apiService.getMessages(conversationId);
      final messages = (response as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
      
      state = state.copyWith(
        status: AdminChatDetailStatus.loaded,
        messages: messages,
      );
    } catch (e) {
      state = state.copyWith(
        status: AdminChatDetailStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> sendMessage(String body) async {
    try {
      final response = await _apiService.sendMessage(conversationId, body);
      final message = Message.fromJson(response);
      
      state = state.copyWith(
        messages: [...state.messages, message],
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  void _subscribeToConversation() {
    if (_pusher == null) return;
    
    final channelName = 'private-conversation.$conversationId';
    // TODO: Subscribe to channel
    // _pusher.subscribe(channelName);
  }

  @override
  void dispose() {
    if (_pusher != null) {
      final channelName = 'private-conversation.$conversationId';
      // TODO: Unsubscribe from channel
      // _pusher.unsubscribe(channelName);
    }
    super.dispose();
  }
}

// Provider
final adminChatDetailProvider =
    StateNotifierProvider.family<AdminChatDetailNotifier, AdminChatDetailState, int>((ref, id) {
  return AdminChatDetailNotifier(ref.watch(apiServiceProvider), id);
});
