<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CropRequest;
use App\Http\Resources\CropResource;
use App\Models\Crop;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CropController extends Controller
{
    /**
     * Get all crops with optional filtering
     */
    public function index(Request $request): JsonResponse
    {
        $query = Crop::with(['farmer']);

        // Filter by type
        if ($request->has('type') && $request->type) {
            $query->byType($request->type);
        }

        // Filter by region
        if ($request->has('region') && $request->region) {
            $query->byRegion($request->region);
        }

        // Filter by price range
        if ($request->has('min_price') && $request->has('max_price')) {
            $query->priceRange($request->min_price, $request->max_price);
        }

        // Filter by availability date
        if ($request->has('availability_date')) {
            $query->availableByDate($request->availability_date);
        }

        // Only show available crops for buyers
        if ($request->user()->isBuyer()) {
            $query->available();
        }

        // Show only farmer's crops for farmers
        if ($request->user()->isFarmer()) {
            $query->byFarmer($request->user()->id);
        }

        $crops = $query->latest()->paginate(20);

        return response()->json([
            'crops' => CropResource::collection($crops),
            'pagination' => [
                'current_page' => $crops->currentPage(),
                'last_page' => $crops->lastPage(),
                'per_page' => $crops->perPage(),
                'total' => $crops->total(),
            ]
        ]);
    }

    /**
     * Get a specific crop
     */
    public function show(Crop $crop): JsonResponse
    {
        return response()->json([
            'crop' => new CropResource($crop->load('farmer'))
        ]);
    }

    /**
     * Create a new crop (farmers only)
     */
    public function store(CropRequest $request): JsonResponse
    {
        if (!$request->user()->isFarmer()) {
            return response()->json([
                'message' => 'Only farmers can create crops'
            ], 403);
        }

        $data = $request->validated();
        $data['farmer_id'] = $request->user()->id;
        $data['status'] = Crop::STATUS_AVAILABLE;

        // Handle image upload
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('crops', 'public');
            $data['image_path'] = $path;
        }

        $crop = Crop::create($data);

        return response()->json([
            'crop' => new CropResource($crop->load('farmer')),
            'message' => 'Crop created successfully'
        ], 201);
    }

    /**
     * Update a crop (farmers can only update their own crops)
     */
    public function update(CropRequest $request, Crop $crop): JsonResponse
    {
        if (!$request->user()->isFarmer()) {
            return response()->json([
                'message' => 'Only farmers can update crops'
            ], 403);
        }

        if ($crop->farmer_id !== $request->user()->id) {
            return response()->json([
                'message' => 'You can only update your own crops'
            ], 403);
        }

        $data = $request->validated();

        // Handle image upload
        if ($request->hasFile('image')) {
            // Delete old image if exists
            if ($crop->image_path) {
                Storage::disk('public')->delete($crop->image_path);
            }
            
            $path = $request->file('image')->store('crops', 'public');
            $data['image_path'] = $path;
        }

        $crop->update($data);

        return response()->json([
            'crop' => new CropResource($crop->load('farmer')),
            'message' => 'Crop updated successfully'
        ]);
    }

    /**
     * Delete a crop (farmers can only delete their own crops)
     */
    public function destroy(Request $request, Crop $crop): JsonResponse
    {
        if (!$request->user()->isFarmer()) {
            return response()->json([
                'message' => 'Only farmers can delete crops'
            ], 403);
        }

        if ($crop->farmer_id !== $request->user()->id) {
            return response()->json([
                'message' => 'You can only delete your own crops'
            ], 403);
        }

        // Check if crop has active orders
        if ($crop->activeOrders()->exists()) {
            return response()->json([
                'message' => 'Cannot delete crop with active orders'
            ], 400);
        }

        // Delete image if exists
        if ($crop->image_path) {
            Storage::disk('public')->delete($crop->image_path);
        }

        $crop->delete();

        return response()->json([
            'message' => 'Crop deleted successfully'
        ]);
    }

    /**
     * Get crop types for filtering
     */
    public function types(): JsonResponse
    {
        $types = Crop::distinct()->pluck('type')->filter()->values();

        return response()->json([
            'types' => $types
        ]);
    }

    /**
     * Get regions for filtering
     */
    public function regions(): JsonResponse
    {
        $regions = Crop::distinct()->pluck('location')->filter()->values();

        return response()->json([
            'regions' => $regions
        ]);
    }

    /**
     * Update crop status (farmers only)
     */
    public function updateStatus(Request $request, Crop $crop): JsonResponse
    {
        if (!$request->user()->isFarmer()) {
            return response()->json([
                'message' => 'Only farmers can update crop status'
            ], 403);
        }

        if ($crop->farmer_id !== $request->user()->id) {
            return response()->json([
                'message' => 'You can only update your own crops'
            ], 403);
        }

        $request->validate([
            'status' => 'required|in:' . implode(',', Crop::getStatuses())
        ]);

        $crop->update(['status' => $request->status]);

        return response()->json([
            'crop' => new CropResource($crop->load('farmer')),
            'message' => 'Crop status updated successfully'
        ]);
    }

    /**
     * Get farmer's crops statistics
     */
    public function statistics(Request $request): JsonResponse
    {
        if (!$request->user()->isFarmer()) {
            return response()->json([
                'message' => 'Only farmers can view crop statistics'
            ], 403);
        }

        $farmer = $request->user();

        $statistics = [
            'total_crops' => $farmer->crops()->count(),
            'available_crops' => $farmer->crops()->where('status', Crop::STATUS_AVAILABLE)->count(),
            'sold_crops' => $farmer->crops()->where('status', Crop::STATUS_SOLD)->count(),
            'reserved_crops' => $farmer->crops()->where('status', Crop::STATUS_RESERVED)->count(),
            'total_value' => $farmer->crops()->where('status', Crop::STATUS_AVAILABLE)->sum(\DB::raw('price * quantity')),
        ];

        return response()->json([
            'statistics' => $statistics
        ]);
    }
} 