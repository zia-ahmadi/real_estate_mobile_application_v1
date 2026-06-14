<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Middleware\IsAdmin;
use App\Http\Resources\PropertyCollection;
use App\Http\Resources\PropertyResource;
use App\Models\Property;
use App\Models\PropertyImage;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class PropertyController extends Controller
{
    /**
     * Display a listing of properties.
     */
    public function index(): PropertyCollection
    {
        $properties = Property::with('coverImage')
            ->where('status', 'available')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return new PropertyCollection($properties);
    }

    /**
     * Store a newly created property.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'area' => 'required|numeric|min:0',
            'bedrooms' => 'required|integer|min:0',
            'bathrooms' => 'required|integer|min:0',
            'city' => 'required|string|max:255',
            'address' => 'required|string|max:255',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'status' => ['nullable', Rule::in(['available', 'sold'])],
            'is_featured' => 'nullable|boolean',
            'images' => 'required|array|min:1',
            'images.*' => 'image|mimes:jpeg,jpg,png|max:5120',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $property = Property::create([
            'title' => $request->title,
            'description' => $request->description,
            'price' => $request->price,
            'area' => $request->area,
            'bedrooms' => $request->bedrooms,
            'bathrooms' => $request->bathrooms,
            'city' => $request->city,
            'address' => $request->address,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'status' => $request->status ?? 'available',
            'is_featured' => $request->is_featured ?? false,
        ]);

        // Upload images
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('properties', 'public');
                
                PropertyImage::create([
                    'property_id' => $property->id,
                    'image_path' => $path,
                    'is_cover' => $index === 0, // First image is cover
                ]);
            }
        }

        return response()->json([
            'message' => 'Property created successfully',
            'data' => new PropertyResource($property->load('images')),
        ], 201);
    }

    /**
     * Display the specified property.
     */
    public function show(Property $property): PropertyResource
    {
        $property->load('images');
        
        return new PropertyResource($property);
    }

    /**
     * Update the specified property.
     */
    public function update(Request $request, Property $property): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'price' => 'sometimes|required|numeric|min:0',
            'area' => 'sometimes|required|numeric|min:0',
            'bedrooms' => 'sometimes|required|integer|min:0',
            'bathrooms' => 'sometimes|required|integer|min:0',
            'city' => 'sometimes|required|string|max:255',
            'address' => 'sometimes|required|string|max:255',
            'latitude' => 'sometimes|required|numeric|between:-90,90',
            'longitude' => 'sometimes|required|numeric|between:-180,180',
            'status' => ['nullable', Rule::in(['available', 'sold'])],
            'is_featured' => 'nullable|boolean',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,jpg,png|max:5120',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $property->update($request->only([
            'title', 'description', 'price', 'area', 'bedrooms', 'bathrooms',
            'city', 'address', 'latitude', 'longitude', 'status', 'is_featured'
        ]));

        // Handle new images if provided
        if ($request->hasFile('images')) {
            // Delete old images
            foreach ($property->images as $oldImage) {
                Storage::disk('public')->delete($oldImage->image_path);
                $oldImage->delete();
            }

            // Upload new images
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('properties', 'public');
                
                PropertyImage::create([
                    'property_id' => $property->id,
                    'image_path' => $path,
                    'is_cover' => $index === 0,
                ]);
            }
        }

        return response()->json([
            'message' => 'Property updated successfully',
            'data' => new PropertyResource($property->load('images')),
        ]);
    }

    /**
     * Remove the specified property.
     */
    public function destroy(Property $property): JsonResponse
    {
        // Delete all associated images from storage
        foreach ($property->images as $image) {
            Storage::disk('public')->delete($image->image_path);
        }

        // Delete property (images will be cascade deleted from database)
        $property->delete();

        return response()->json([
            'message' => 'Property deleted successfully',
        ]);
    }

    /**
     * Search and filter properties.
     */
    public function search(Request $request): PropertyCollection
    {
        $query = Property::with('coverImage')
            ->where('status', 'available');

        // Filter by city
        if ($request->has('city')) {
            $query->where('city', 'like', '%' . $request->city . '%');
        }

        // Filter by price range
        if ($request->has('min_price')) {
            $query->where('price', '>=', $request->min_price);
        }
        if ($request->has('max_price')) {
            $query->where('price', '<=', $request->max_price);
        }

        // Filter by bedrooms
        if ($request->has('bedrooms')) {
            $query->where('bedrooms', '>=', $request->bedrooms);
        }

        // Filter by area range
        if ($request->has('min_area')) {
            $query->where('area', '>=', $request->min_area);
        }
        if ($request->has('max_area')) {
            $query->where('area', '<=', $request->max_area);
        }

        $properties = $query->orderBy('created_at', 'desc')
            ->paginate(10);

        return new PropertyCollection($properties);
    }
}
