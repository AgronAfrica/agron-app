<?php

namespace App\Http\Controllers;

use App\Models\Crop;
use Illuminate\Http\Request;

class CropController extends Controller
{
    public function index(Request $request)
    {
        $query = Crop::with('user');

        // Filter by category
        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by price range
        if ($request->has('min_price')) {
            $query->where('price_per_kg', '>=', $request->min_price);
        }

        if ($request->has('max_price')) {
            $query->where('price_per_kg', '<=', $request->max_price);
        }

        // Search by name
        if ($request->has('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        $crops = $query->latest()->paginate(20);

        return response()->json($crops);
    }

    public function show(Crop $crop)
    {
        return response()->json([
            'crop' => $crop->load('user'),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price_per_kg' => 'required|numeric|min:0',
            'quantity_available' => 'required|numeric|min:0',
            'harvest_date' => 'required|date',
            'location' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'status' => 'required|in:available,sold,reserved',
            'image' => 'nullable|string',
        ]);

        $crop = Crop::create([
            'user_id' => $request->user()->id,
            'name' => $request->name,
            'description' => $request->description,
            'price_per_kg' => $request->price_per_kg,
            'quantity_available' => $request->quantity_available,
            'harvest_date' => $request->harvest_date,
            'location' => $request->location,
            'category' => $request->category,
            'status' => $request->status,
            'image' => $request->image,
        ]);

        return response()->json([
            'message' => 'Crop created successfully',
            'crop' => $crop->load('user'),
        ], 201);
    }

    public function update(Request $request, Crop $crop)
    {
        // Check if user owns the crop
        if ($crop->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'price_per_kg' => 'sometimes|numeric|min:0',
            'quantity_available' => 'sometimes|numeric|min:0',
            'harvest_date' => 'sometimes|date',
            'location' => 'sometimes|string|max:255',
            'category' => 'sometimes|string|max:100',
            'status' => 'sometimes|in:available,sold,reserved',
            'image' => 'nullable|string',
        ]);

        $crop->update($request->all());

        return response()->json([
            'message' => 'Crop updated successfully',
            'crop' => $crop->load('user'),
        ]);
    }

    public function destroy(Request $request, Crop $crop)
    {
        // Check if user owns the crop
        if ($crop->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $crop->delete();

        return response()->json([
            'message' => 'Crop deleted successfully',
        ]);
    }
} 