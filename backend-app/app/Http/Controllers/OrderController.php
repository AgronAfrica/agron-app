<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Crop;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Order::with(['crop', 'user']);

        // Filter orders based on user role
        if ($user->isFarmer()) {
            $query->whereHas('crop', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            });
        } elseif ($user->isBuyer()) {
            $query->where('user_id', $user->id);
        } elseif ($user->isTransporter()) {
            $query->whereHas('deliveryJob', function ($q) use ($user) {
                $q->where('transporter_id', $user->id);
            });
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $orders = $query->latest()->paginate(20);

        return response()->json($orders);
    }

    public function userOrders(Request $request)
    {
        $user = $request->user();
        $query = Order::with(['crop', 'user']);

        // Filter orders based on user role
        if ($user->isFarmer()) {
            $query->whereHas('crop', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            });
        } elseif ($user->isBuyer()) {
            $query->where('user_id', $user->id);
        } elseif ($user->isTransporter()) {
            $query->whereHas('deliveryJob', function ($q) use ($user) {
                $q->where('transporter_id', $user->id);
            });
        }

        $orders = $query->latest()->get();

        return response()->json($orders);
    }

    public function show(Order $order)
    {
        $user = request()->user();

        // Check authorization
        if (!$user->isFarmer() && $order->user_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        return response()->json([
            'order' => $order->load(['crop', 'user', 'deliveryJob']),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'crop_id' => 'required|exists:crops,id',
            'quantity' => 'required|numeric|min:0.1',
            'delivery_address' => 'required|string|max:500',
            'delivery_date' => 'required|date|after:today',
            'payment_method' => 'required|in:cash,card,mobile_money',
            'notes' => 'nullable|string|max:1000',
        ]);

        $crop = Crop::findOrFail($request->crop_id);

        // Check if crop is available
        if ($crop->status !== 'available') {
            return response()->json([
                'message' => 'Crop is not available for purchase',
            ], 400);
        }

        // Check if requested quantity is available
        if ($crop->quantity_available < $request->quantity) {
            return response()->json([
                'message' => 'Requested quantity is not available',
            ], 400);
        }

        $totalPrice = $crop->price_per_kg * $request->quantity;

        $order = Order::create([
            'user_id' => $request->user()->id,
            'crop_id' => $request->crop_id,
            'quantity' => $request->quantity,
            'total_price' => $totalPrice,
            'status' => 'pending',
            'delivery_address' => $request->delivery_address,
            'delivery_date' => $request->delivery_date,
            'payment_method' => $request->payment_method,
            'notes' => $request->notes,
        ]);

        // Update crop quantity
        $crop->decrement('quantity_available', $request->quantity);

        // Update crop status if no quantity left
        if ($crop->quantity_available <= 0) {
            $crop->update(['status' => 'sold']);
        }

        return response()->json([
            'message' => 'Order created successfully',
            'order' => $order->load(['crop', 'user']),
        ], 201);
    }

    public function update(Request $request, Order $order)
    {
        $user = $request->user();

        // Check authorization
        if (!$user->isFarmer() && $order->user_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $request->validate([
            'status' => 'sometimes|in:pending,confirmed,shipped,delivered,cancelled',
            'delivery_date' => 'sometimes|date|after:today',
            'notes' => 'nullable|string|max:1000',
        ]);

        $order->update($request->all());

        return response()->json([
            'message' => 'Order updated successfully',
            'order' => $order->load(['crop', 'user']),
        ]);
    }

    public function destroy(Request $request, Order $order)
    {
        $user = $request->user();

        // Only buyers can cancel their own orders
        if ($order->user_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        // Only allow cancellation of pending orders
        if ($order->status !== 'pending') {
            return response()->json([
                'message' => 'Cannot cancel order that is not pending',
            ], 400);
        }

        // Restore crop quantity
        $crop = $order->crop;
        $crop->increment('quantity_available', $order->quantity);

        // Update crop status back to available if it was sold
        if ($crop->status === 'sold' && $crop->quantity_available > 0) {
            $crop->update(['status' => 'available']);
        }

        $order->delete();

        return response()->json([
            'message' => 'Order cancelled successfully',
        ]);
    }

    public function updateStatus(Request $request, Order $order)
    {
        $user = $request->user();

        // Check authorization - only farmer, buyer, or assigned transporter can update status
        if (!$user->isFarmer() && $order->user_id !== $user->id && $order->transporter_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $request->validate([
            'status' => 'required|in:pending,confirmed,shipped,delivered,cancelled',
        ]);

        $order->update(['status' => $request->status]);

        return response()->json([
            'message' => 'Order status updated successfully',
            'order' => $order->load(['crop', 'user']),
        ]);
    }
} 