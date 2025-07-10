<?php

namespace App\Http\Controllers;

use App\Models\Crop;
use App\Models\Order;
use App\Models\DeliveryJob;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    /**
     * Display a listing of user's orders.
     */
    public function userOrders(Request $request)
    {
        $orders = Order::with(['crop', 'buyer', 'farmer', 'transporter'])
            ->forUser(Auth::id())
            ->latest()
            ->get();

        // Transform data for iOS app
        $orders = $orders->map(function ($order) {
            return [
                'id' => $order->id,
                'crop_id' => $order->crop_id,
                'crop_name' => $order->crop->name,
                'buyer_id' => $order->buyer_id,
                'buyer_name' => $order->buyer->name,
                'farmer_id' => $order->farmer_id,
                'farmer_name' => $order->farmer->name,
                'quantity' => (float) $order->quantity,
                'unit' => $order->unit,
                'total_price' => (float) $order->total_price,
                'currency' => $order->currency,
                'status' => $order->status,
                'pickup_location' => $order->pickup_location,
                'delivery_location' => $order->delivery_location,
                'transporter_id' => $order->transporter_id,
                'transporter_name' => $order->transporter ? $order->transporter->name : null,
                'created_at' => $order->created_at->format('Y-m-d\TH:i:s.u\Z'),
                'updated_at' => $order->updated_at->format('Y-m-d\TH:i:s.u\Z'),
            ];
        });

        return response()->json($orders);
    }

    /**
     * Store a newly created order.
     */
    public function store(Request $request)
    {
        $request->validate([
            'crop_id' => 'required|exists:crops,id',
            'quantity' => 'required|numeric|min:0.1',
            'pickup_location' => 'required|string|max:255',
            'delivery_location' => 'nullable|string|max:255',
        ]);

        $crop = Crop::findOrFail($request->crop_id);

        // Check if crop is available
        if (!$crop->isAvailable()) {
            return response()->json(['message' => 'Crop is not available'], 400);
        }

        // Check if requested quantity is available
        if (!$crop->canPurchase($request->quantity)) {
            return response()->json(['message' => 'Requested quantity not available'], 400);
        }

        // Calculate total price
        $totalPrice = $crop->price * $request->quantity;

        DB::beginTransaction();

        try {
            // Create order
            $order = Order::create([
                'crop_id' => $request->crop_id,
                'buyer_id' => Auth::id(),
                'farmer_id' => $crop->farmer_id,
                'quantity' => $request->quantity,
                'unit' => $crop->unit,
                'total_price' => $totalPrice,
                'currency' => $crop->currency,
                'status' => 'pending',
                'pickup_location' => $request->pickup_location,
                'delivery_location' => $request->delivery_location,
            ]);

            // Update crop quantity
            $crop->updateQuantityAfterPurchase($request->quantity);

            // Create delivery job if delivery location is specified
            if ($request->delivery_location) {
                DeliveryJob::create([
                    'order_id' => $order->id,
                    'status' => 'open',
                ]);
            }

            DB::commit();

            return response()->json($order, 201);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json(['message' => 'Failed to create order'], 500);
        }
    }

    /**
     * Display the specified order.
     */
    public function show(Order $order)
    {
        // Check if user has access to this order
        if (!in_array(Auth::id(), [$order->buyer_id, $order->farmer_id, $order->transporter_id])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $order->load(['crop', 'buyer', 'farmer', 'transporter']);

        return response()->json([
            'id' => $order->id,
            'crop_id' => $order->crop_id,
            'crop_name' => $order->crop->name,
            'buyer_id' => $order->buyer_id,
            'buyer_name' => $order->buyer->name,
            'farmer_id' => $order->farmer_id,
            'farmer_name' => $order->farmer->name,
            'quantity' => (float) $order->quantity,
            'unit' => $order->unit,
            'total_price' => (float) $order->total_price,
            'currency' => $order->currency,
            'status' => $order->status,
            'pickup_location' => $order->pickup_location,
            'delivery_location' => $order->delivery_location,
            'transporter_id' => $order->transporter_id,
            'transporter_name' => $order->transporter ? $order->transporter->name : null,
            'created_at' => $order->created_at->format('Y-m-d\TH:i:s.u\Z'),
            'updated_at' => $order->updated_at->format('Y-m-d\TH:i:s.u\Z'),
        ]);
    }

    /**
     * Update order status.
     */
    public function updateStatus(Request $request, Order $order)
    {
        $request->validate([
            'status' => 'required|string|in:pending,confirmed,in_transit,delivered,cancelled',
        ]);

        $user = Auth::user();
        $newStatus = $request->status;

        // Check permissions based on user role and current status
        if ($user->isFarmer() && $order->farmer_id === $user->id) {
            // Farmer can confirm or cancel orders
            if ($newStatus === 'confirmed' && $order->status === 'pending') {
                $order->confirm();
            } elseif ($newStatus === 'cancelled' && in_array($order->status, ['pending', 'confirmed'])) {
                $order->cancel();
            } else {
                return response()->json(['message' => 'Invalid status transition'], 400);
            }
        } elseif ($user->isTransporter() && $order->transporter_id === $user->id) {
            // Transporter can mark as in transit or delivered
            if ($newStatus === 'in_transit' && $order->status === 'confirmed') {
                $order->markInTransit();
            } elseif ($newStatus === 'delivered' && $order->status === 'in_transit') {
                $order->markDelivered();
            } else {
                return response()->json(['message' => 'Invalid status transition'], 400);
            }
        } else {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json($order);
    }
} 