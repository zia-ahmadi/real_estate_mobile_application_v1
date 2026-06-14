<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    /**
     * Get authenticated user's conversation (create if none exists).
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $conversation = Conversation::firstOrCreate(
            ['user_id' => $user->id]
        );

        return response()->json([
            'data' => [
                'id' => $conversation->id,
                'user_id' => $conversation->user_id,
                'created_at' => $conversation->created_at,
                'updated_at' => $conversation->updated_at,
            ],
        ]);
    }

    /**
     * Get ALL conversations with last message + user info (admin only).
     */
    public function adminIndex(Request $request): JsonResponse
    {
        $conversations = Conversation::with(['user', 'messages' => function ($query) {
            $query->latest()->limit(1);
        }])
        ->withCount('messages')
        ->orderBy('updated_at', 'desc')
        ->get()
        ->map(function ($conversation) {
            $lastMessage = $conversation->messages->first();
            
            return [
                'id' => $conversation->id,
                'user' => [
                    'id' => $conversation->user->id,
                    'name' => $conversation->user->name,
                    'email' => $conversation->user->email,
                ],
                'last_message' => $lastMessage ? [
                    'id' => $lastMessage->id,
                    'body' => $lastMessage->body,
                    'sender_id' => $lastMessage->sender_id,
                    'created_at' => $lastMessage->created_at,
                ] : null,
                'messages_count' => $conversation->messages_count,
                'updated_at' => $conversation->updated_at,
            ];
        });

        return response()->json([
            'data' => $conversations,
        ]);
    }
}
