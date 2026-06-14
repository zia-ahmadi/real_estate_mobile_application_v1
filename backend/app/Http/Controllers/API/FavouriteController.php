<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\PropertyResource;
use App\Models\Favourite;
use App\Models\Property;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavouriteController extends Controller
{
    /**
     * Toggle favourite for a property.
     */
    public function toggle(Property $property): JsonResponse
    {
        $user = auth()->user();
        
        $favourite = Favourite::where('user_id', $user->id)
            ->where('property_id', $property->id)
            ->first();

        if ($favourite) {
            $favourite->delete();
            $isFavourited = false;
        } else {
            Favourite::create([
                'user_id' => $user->id,
                'property_id' => $property->id,
            ]);
            $isFavourited = true;
        }

        return response()->json([
            'success' => true,
            'is_favourited' => $isFavourited,
        ]);
    }

    /**
     * Get authenticated user's favourited properties.
     */
    public function index(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        $favourites = Favourite::where('user_id', $user->id)
            ->with('property.coverImage')
            ->get()
            ->map(function ($favourite) {
                return new PropertyResource($favourite->property);
            });

        return response()->json([
            'data' => $favourites,
        ]);
    }
}
