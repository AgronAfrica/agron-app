<?php

namespace App\Http\Controllers;

use App\Models\Crop;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CropController extends Controller
{
    /**
     * Display a listing of crops.
     */
    public function index(Request $request)
    {
        $query = Crop::with('farmer');

        // Filter by type
        if ($request->has('type') && $request->type !== 'All') {
            $query->byType($request->type);
        }

        // Filter by region/location
        if ($request->has('region') && $request->region !== 'All') {
            $query->byLocation($request->region);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Get user's crops if farmer
        if (Auth::user()->isFarmer()) {
            $query->where('farmer_id', Auth::id());
        }

        $crops = $query->latest()->get();

        // Transform data for iOS app
        $crops = $crops->map(function ($crop) {
            return [
                'id' => $crop->id,
                'name' => $crop->name,
                'type' => $crop->type,
                'quantity' => (float) $crop->quantity,
                'unit' => $crop->unit,
                'price' => (float) $crop->price,
                'currency' => $crop->currency,
                'location' => $crop->location,
                'availability_date' => $crop->availability_date->format('Y-m-d'),
                'description' => $crop->description,
                'farmer_id' => $crop->farmer_id,
                'farmer_name' => $crop->farmer->name,
                'status' => $crop->status,
                'created_at' => $crop->created_at->format('Y-m-d'),
            ];
        });

        return response()->json($crops);
    }

    /**
     * Store a newly created crop.
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:255',
            'quantity' => 'required|numeric|min:0.1',
            'unit' => 'required|string|max:50',
            'price' => 'required|numeric|min:0',
            'currency' => 'required|string|max:10',
            'location' => 'required|string|max:255',
            'availability_date' => 'required|date',
            'description' => 'nullable|string',
        ]);

        $crop = Crop::create([
            'name' => $request->name,
            'type' => $request->type,
            'quantity' => $request->quantity,
            'unit' => $request->unit,
            'price' => $request->price,
            'currency' => $request->currency,
            'location' => $request->location,
            'availability_date' => $request->availability_date,
            'description' => $request->description,
            'farmer_id' => Auth::id(),
            'status' => 'available',
        ]);

        return response()->json($crop, 201);
    }

    /**
     * Display the specified crop.
     */
    public function show(Crop $crop)
    {
        $crop->load('farmer');

        return response()->json([
            'id' => $crop->id,
            'name' => $crop->name,
            'type' => $crop->type,
            'quantity' => (float) $crop->quantity,
            'unit' => $crop->unit,
            'price' => (float) $crop->price,
            'currency' => $crop->currency,
            'location' => $crop->location,
            'availability_date' => $crop->availability_date->format('Y-m-d'),
            'description' => $crop->description,
            'farmer_id' => $crop->farmer_id,
            'farmer_name' => $crop->farmer->name,
            'status' => $crop->status,
            'created_at' => $crop->created_at->format('Y-m-d'),
        ]);
    }

    /**
     * Update the specified crop.
     */
    public function update(Request $request, Crop $crop)
    {
        // Check if user owns this crop
        if ($crop->farmer_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'type' => 'sometimes|string|max:255',
            'quantity' => 'sometimes|numeric|min:0.1',
            'unit' => 'sometimes|string|max:50',
            'price' => 'sometimes|numeric|min:0',
            'currency' => 'sometimes|string|max:10',
            'location' => 'sometimes|string|max:255',
            'availability_date' => 'sometimes|date',
            'description' => 'sometimes|nullable|string',
            'status' => 'sometimes|string|in:available,sold,reserved',
        ]);

        $crop->update($request->only([
            'name', 'type', 'quantity', 'unit', 'price', 'currency',
            'location', 'availability_date', 'description', 'status'
        ]));

        return response()->json($crop);
    }

    /**
     * Remove the specified crop.
     */
    public function destroy(Crop $crop)
    {
        // Check if user owns this crop
        if ($crop->farmer_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $crop->delete();

        return response()->json(['message' => 'Crop deleted successfully']);
    }
} 