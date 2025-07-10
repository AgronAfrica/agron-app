<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\OrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Crop;
use App\Models\Order;
use App\Models\DeliveryJob;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    /**
     * Get user's orders
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Order::with(['crop', 'farmer', 'buyer', 'transporter']);

        // Filter orders based on user role
        if ($user->isFarmer()) {
            $query->byFarmer($user->id);
        } elseif ($user->isBuyer()) {
            $query->byBuyer($user->id);
        } elseif ($user->isTransporter()) {
            $query->byTransporter($user->id);
        }

        // Filter by status
        if ($request->has('status') && $request->status) {
            $query->byStatus($request->status);
        }

        $orders = $query->latest()->paginate(20);

        return response()->json([
            'orders' => OrderResource::collection($orders),
            'pagination' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'per_page' => $orders->perPage(),
                'total' => $orders->total(),
            ]
        ]);
    }

    /**
     * Get a specific order
     */
    public function show(Order $order): JsonResponse
    {
        return response()->json([
            'order' => new OrderResource($order->load(['crop', 'farmer', 'buyer', 'transporter']))
        ]);
    }

    /**
     * Create a new order (buyers only)
     */
    public function store(OrderRequest $request): JsonResponse
    {
        if (!$request->user()->isBuyer()) {
            return response()->json([
                'message' => 'Only buyers can create orders'
            ], 403);
        }

        $crop = Crop::findOrFail($request->crop_id);

        // Check if crop is available
        if (!$crop->isAvailable()) {
            return response()->json([
                'message' => 'Crop is not available for purchase'
            ], 400);
        }

        // Check if requested quantity is available
        if ($crop->quantity < $request->quantity) {
            return response()->json([
                'message' => 'Requested quantity exceeds available quantity'
            ], 400);
        }

        // Calculate total price
        $totalPrice = $crop->getTotalPrice($request->quantity);

        $order = Order::create([
            'crop_id' => $crop->id,
            'buyer_id' => $request->user()->id,
            'farmer_id' => $crop->farmer_id,
            'quantity' => $request->quantity,
            'unit' => $crop->unit,
            'total_price' => $totalPrice,
            'currency' => $crop->currency,
            'status' => Order::STATUS_PENDING,
            'pickup_location' => $request->pickup_location,
            'delivery_location' => $request->delivery_location,
        ]);

        // Update crop quantity
        $crop->quantity -= $request->quantity;
        if ($crop->quantity <= 0) {
            $crop->status = Crop::STATUS_SOLD;
        }
        $crop->save();

        // Create delivery job
        DeliveryJob::create([
            'order_id' => $order->id,
            'status' => DeliveryJob::STATUS_OPEN,
            'pickup_location' => $request->pickup_location,
            'delivery_location' => $request->delivery_location ?? $request->pickup_location,
        ]);

        return response()->json([
            'order' => new OrderResource($order->load(['crop', 'farmer', 'buyer'])),
            'message' => 'Order created successfully'
        ], 201);
    }

    /**
     * Update order status
     */
    public function updateStatus(Request $request, Order $order): JsonResponse
    {
        $user = $request->user();

        $request->validate([
            'status' => 'required|in:' . implode(',', Order::getStatuses())
        ]);

        $newStatus = $request->status;

        // Check permissions based on user role
        if ($user->isFarmer()) {
            if ($order->farmer_id !== $user->id) {
                return response()->json([
                    'message' => 'You can only update orders for your crops'
                ], 403);
            }

            // Farmers can only confirm or ship orders
            if (!in_array($newStatus, [Order::STATUS_CONFIRMED, Order::STATUS_IN_TRANSIT])) {
                return response()->json([
                    'message' => 'Invalid status for farmer'
                ], 400);
            }
        } elseif ($user->isBuyer()) {
            if ($order->buyer_id !== $user->id) {
                return response()->json([
                    'message' => 'You can only update your own orders'
                ], 403);
            }

            // Buyers can only cancel orders
            if ($newStatus !== Order::STATUS_CANCELLED) {
                return response()->json([
                    'message' => 'Buyers can only cancel orders'
                ], 400);
            }
        } elseif ($user->isTransporter()) {
            if ($order->transporter_id !== $user->id) {
                return response()->json([
                    'message' => 'You can only update orders you are transporting'
                ], 403);
            }

            // Transporters can only mark as delivered
            if ($newStatus !== Order::STATUS_DELIVERED) {
                return response()->json([
                    'message' => 'Transporters can only mark orders as delivered'
                ], 400);
            }
        }

        // Update order status
        $order->update(['status' => $newStatus]);

        // Update delivery job status if order is delivered
        if ($newStatus === Order::STATUS_DELIVERED) {
            $order->deliveryJob()->update(['status' => DeliveryJob::STATUS_DELIVERED]);
        }

        return response()->json([
            'order' => new OrderResource($order->load(['crop', 'farmer', 'buyer', 'transporter'])),
            'message' => 'Order status updated successfully'
        ]);
    }

    /**
     * Cancel order (buyers only)
     */
    public function cancel(Request $request, Order $order): JsonResponse
    {
        if (!$request->user()->isBuyer()) {
            return response()->json([
                'message' => 'Only buyers can cancel orders'
            ], 403);
        }

        if ($order->buyer_id !== $request->user()->id) {
            return response()->json([
                'message' => 'You can only cancel your own orders'
            ], 403);
        }

        if (!$order->canBeCancelled()) {
            return response()->json([
                'message' => 'Order cannot be cancelled at this stage'
            ], 400);
        }

        $order->update(['status' => Order::STATUS_CANCELLED]);

        // Restore crop quantity
        $crop = $order->crop;
        $crop->quantity += $order->quantity;
        if ($crop->status === Crop::STATUS_SOLD) {
            $crop->status = Crop::STATUS_AVAILABLE;
        }
        $crop->save();

        // Cancel delivery job
        if ($order->deliveryJob) {
            $order->deliveryJob->update(['status' => DeliveryJob::STATUS_CANCELLED]);
        }

        return response()->json([
            'order' => new OrderResource($order->load(['crop', 'farmer', 'buyer'])),
            'message' => 'Order cancelled successfully'
        ]);
    }

    /**
     * Get order statistics
     */
    public function statistics(Request $request): JsonResponse
    {
        $user = $request->user();
        $statistics = [];

        if ($user->isFarmer()) {
            $statistics = [
                'total_orders' => $user->farmerOrders()->count(),
                'pending_orders' => $user->farmerOrders()->where('status', Order::STATUS_PENDING)->count(),
                'confirmed_orders' => $user->farmerOrders()->where('status', Order::STATUS_CONFIRMED)->count(),
                'in_transit_orders' => $user->farmerOrders()->where('status', Order::STATUS_IN_TRANSIT)->count(),
                'delivered_orders' => $user->farmerOrders()->where('status', Order::STATUS_DELIVERED)->count(),
                'total_sales' => $user->farmerOrders()->where('status', Order::STATUS_DELIVERED)->sum('total_price'),
            ];
        } elseif ($user->isBuyer()) {
            $statistics = [
                'total_orders' => $user->buyerOrders()->count(),
                'pending_orders' => $user->buyerOrders()->where('status', Order::STATUS_PENDING)->count(),
                'confirmed_orders' => $user->buyerOrders()->where('status', Order::STATUS_CONFIRMED)->count(),
                'in_transit_orders' => $user->buyerOrders()->where('status', Order::STATUS_IN_TRANSIT)->count(),
                'delivered_orders' => $user->buyerOrders()->where('status', Order::STATUS_DELIVERED)->count(),
                'cancelled_orders' => $user->buyerOrders()->where('status', Order::STATUS_CANCELLED)->count(),
                'total_spent' => $user->buyerOrders()->where('status', Order::STATUS_DELIVERED)->sum('total_price'),
            ];
        }

        return response()->json([
            'statistics' => $statistics
        ]);
    }
} 