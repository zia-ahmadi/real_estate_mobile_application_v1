import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../core/network/api_service.dart';
import '../../properties/providers/property_provider.dart';
import '../data/chat_models.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState {
  final ChatStatus status;
  final Conversation? conversation;
  final List<Message> messages;
  final String? error;

  ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    ChatStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _apiService;
  PusherChannelsFlutter? _pusher;

  ChatNotifier(this._apiService) : super(ChatState()) {
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
      
      // Add message to list if it belongs to current conversation
      if (state.conversation != null && message.conversationId == state.conversation!.id) {
        state = state.copyWith(
          messages: [...state.messages, message],
        );
      }
    }
  }

  Future<void> loadConversation() async {
    state = state.copyWith(status: ChatStatus.loading, error: null);
    
    try {
      final response = await _apiService.getMyConversation();
      final conversation = Conversation.fromJson(response);
      
      state = state.copyWith(
        status: ChatStatus.loaded,
        conversation: conversation,
      );
      
      // Load messages after conversation is loaded
      await loadMessages(conversation.id);
      
      // Subscribe to Pusher channel
      _subscribeToConversation(conversation.id);
    } catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMessages(int conversationId) async {
    try {
      final response = await _apiService.getMessages(conversationId);
      final messages = (response as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
      
      state = state.copyWith(messages: messages);
    } catch (e) {
      // Don't update state on error, just log
    }
  }

  Future<bool> sendMessage(String body) async {
    if (state.conversation == null) return false;
    
    Message? tempMessage;
    
    try {
      // Optimistically add message to list
      tempMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch,
        conversationId: state.conversation!.id,
        senderId: 0, // Will be filled by server
        body: body,
        createdAt: DateTime.now().toIso8601String(),
      );
      
      state = state.copyWith(
        messages: [...state.messages, tempMessage],
      );
      
      final response = await _apiService.sendMessage(state.conversation!.id, body);
      final message = Message.fromJson(response);
      
      // Replace temp message with actual message
      final updatedMessages = state.messages.map((m) {
        if (m.id == tempMessage!.id) {
          return message;
        }
        return m;
      }).toList();
      
      state = state.copyWith(messages: updatedMessages);
      
      return true;
    } catch (e) {
      // Remove temp message on error
      if (tempMessage != null) {
        final updatedMessages = state.messages.where((m) => m.id != tempMessage!.id).toList();
        state = state.copyWith(messages: updatedMessages);
      }
      return false;
    }
  }

  void _subscribeToConversation(int conversationId) {
    if (_pusher == null) return;
    
    final channelName = 'private-conversation.$conversationId';
    // TODO: Subscribe to channel
    // _pusher.subscribe(channelName);
  }

  void _unsubscribeFromConversation() {
    if (_pusher == null || state.conversation == null) return;
    
    final channelName = 'private-conversation.${state.conversation!.id}';
    // TODO: Unsubscribe from channel
    // _pusher.unsubscribe(channelName);
  }

  @override
  void dispose() {
    _unsubscribeFromConversation();
    _pusher?.disconnect();
    super.dispose();
  }
}

// Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(apiServiceProvider));
});
