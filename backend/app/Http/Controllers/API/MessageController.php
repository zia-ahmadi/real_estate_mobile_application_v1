<?php

namespace App\Http\Controllers\API;

use App\Events\MessageSent;
use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MessageController extends Controller
{
    /**
     * Get all messages in a conversation.
     */
    public function index(Conversation $conversation, Request $request): JsonResponse
    {
        $user = $request->user();
        
        // Check if user is admin or the conversation owner
        if ($user->role !== 'admin' && $conversation->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Mark messages as read (if user is not the sender)
        $conversation->messages()
            ->where('sender_id', '!=', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        $messages = $conversation->messages()
            ->with('sender')
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) {
                return [
                    'id' => $message->id,
                    'body' => $message->body,
                    'sender_id' => $message->sender_id,
                    'sender_name' => $message->sender->name,
                    'read_at' => $message->read_at,
                    'created_at' => $message->created_at,
                ];
            });

        return response()->json([
            'data' => $messages,
        ]);
    }

    /**
     * Send a message and broadcast via Pusher.
     */
    public function store(Conversation $conversation, Request $request): JsonResponse
    {
        $user = $request->user();
        
        // Check if user is admin or the conversation owner
        if ($user->role !== 'admin' && $conversation->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validator = Validator::make($request->all(), [
            'body' => 'required|string|max:5000',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'sender_id' => $user->id,
            'body' => $request->body,
        ]);

        // Broadcast the message
        broadcast(new MessageSent($message));

        return response()->json([
            'message' => 'Message sent successfully',
            'data' => [
                'id' => $message->id,
                'body' => $message->body,
                'sender_id' => $message->sender_id,
                'sender_name' => $user->name,
                'created_at' => $message->created_at,
            ],
        ], 201);
    }
}
