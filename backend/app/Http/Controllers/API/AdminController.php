<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Property;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Get admin dashboard stats.
     */
    public function dashboard(): JsonResponse
    {
        $stats = [
            'total_properties' => Property::count(),
            'available_properties' => Property::where('status', 'available')->count(),
            'sold_properties' => Property::where('status', 'sold')->count(),
            'total_users' => User::where('role', 'user')->count(),
            'total_conversations' => Conversation::count(),
            'new_messages' => Message::whereNull('read_at')->count(),
        ];

        return response()->json([
            'data' => $stats,
        ]);
    }

    /**
     * List all users (paginated).
     */
    public function users(Request $request): JsonResponse
    {
        $users = User::where('role', 'user')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'data' => $users->items(),
            'meta' => [
                'current_page' => $users->currentPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
                'last_page' => $users->lastPage(),
            ],
            'links' => [
                'first' => $users->url(1),
                'last' => $users->url($users->lastPage()),
                'prev' => $users->previousPageUrl(),
                'next' => $users->nextPageUrl(),
            ],
        ]);
    }

    /**
     * Toggle is_blocked status on a user.
     */
    public function toggleBlock(User $user): JsonResponse
    {
        // Prevent blocking admin
        if ($user->role === 'admin') {
            return response()->json([
                'message' => 'Cannot block admin user',
            ], 403);
        }

        $user->update([
            'is_blocked' => !$user->is_blocked,
        ]);

        return response()->json([
            'message' => 'User status updated successfully',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'is_blocked' => $user->is_blocked,
            ],
        ]);
    }
}
