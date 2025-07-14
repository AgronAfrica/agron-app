<?php

namespace App\Http\Controllers;

use App\Models\DeliveryJob;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DeliveryController extends Controller
{
    /**
     * Display a listing of delivery jobs.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $query = DeliveryJob::with(['order.crop', 'order.buyer', 'order.farmer', 'transporter']);

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Get jobs for specific transporter
        if ($user->isTransporter()) {
            $query->where(function($q) use ($user) {
                $q->where('transporter_id', $user->id)
                  ->orWhere('status', 'open');
            });
        }

        $jobs = $query->latest()->get();

        // Transform data for iOS app
        $jobs = $jobs->map(function ($job) {
            return [
                'id' => $job->id,
                'order_id' => $job->order_id,
                'order_number' => $job->order->order_number ?? 'ORD-' . $job->order_id,
                'pickup_location' => $job->order->pickup_location ?? $job->order->delivery_address,
                'delivery_location' => $job->order->delivery_location ?? $job->order->delivery_address,
                'crop_name' => $job->order->crop->name ?? 'Unknown Crop',
                'quantity' => (float) $job->order->quantity,
                'unit' => $job->order->unit ?? 'kg',
                'status' => $job->status,
                'farmer_name' => $job->order->farmer->name ?? 'Unknown Farmer',
                'buyer_name' => $job->order->buyer->name ?? 'Unknown Buyer',
                'transporter_id' => $job->transporter_id,
                'transporter_name' => $job->transporter ? $job->transporter->name : null,
                'estimated_pickup_date' => $job->order->delivery_date ? $job->order->delivery_date->format('Y-m-d') : null,
                'estimated_delivery_date' => $job->order->delivery_date ? $job->order->delivery_date->format('Y-m-d') : null,
                'created_at' => $job->created_at->format('Y-m-d\TH:i:s.u\Z'),
                'updated_at' => $job->updated_at->format('Y-m-d\TH:i:s.u\Z'),
            ];
        });

        return response()->json($jobs);
    }

    /**
     * Accept a delivery job.
     */
    public function acceptJob(Request $request)
    {
        $request->validate([
            'job_id' => 'required|exists:delivery_jobs,id',
        ]);

        $user = $request->user();
        
        if (!$user->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can accept jobs',
            ], 403);
        }

        $job = DeliveryJob::findOrFail($request->job_id);

        if ($job->status !== 'open') {
            return response()->json([
                'message' => 'Job is not available for acceptance',
            ], 400);
        }

        $job->update([
            'transporter_id' => $user->id,
            'status' => 'accepted',
        ]);

        // Update order status
        $job->order->update(['status' => 'confirmed']);

        return response()->json([
            'message' => 'Job accepted successfully',
            'job' => $this->transformJob($job),
        ]);
    }

    /**
     * Mark job as picked up.
     */
    public function markAsPickedUp(Request $request, DeliveryJob $job)
    {
        $user = $request->user();

        if ($job->transporter_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        if ($job->status !== 'accepted') {
            return response()->json([
                'message' => 'Job must be accepted before marking as picked up',
            ], 400);
        }

        $job->update(['status' => 'picked_up']);
        $job->order->update(['status' => 'shipped']);

        return response()->json([
            'message' => 'Job marked as picked up successfully',
            'job' => $this->transformJob($job),
        ]);
    }

    /**
     * Mark job as delivered.
     */
    public function markAsDelivered(Request $request, DeliveryJob $job)
    {
        $user = $request->user();

        if ($job->transporter_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        if ($job->status !== 'picked_up') {
            return response()->json([
                'message' => 'Job must be picked up before marking as delivered',
            ], 400);
        }

        $job->update(['status' => 'delivered']);
        $job->order->update(['status' => 'delivered']);

        return response()->json([
            'message' => 'Job marked as delivered successfully',
            'job' => $this->transformJob($job),
        ]);
    }

    /**
     * Transform job data for iOS app.
     */
    private function transformJob($job)
    {
        return [
            'id' => $job->id,
            'order_id' => $job->order_id,
            'order_number' => $job->order->order_number ?? 'ORD-' . $job->order_id,
            'pickup_location' => $job->order->pickup_location ?? $job->order->delivery_address,
            'delivery_location' => $job->order->delivery_location ?? $job->order->delivery_address,
            'crop_name' => $job->order->crop->name ?? 'Unknown Crop',
            'quantity' => (float) $job->order->quantity,
            'unit' => $job->order->unit ?? 'kg',
            'status' => $job->status,
            'farmer_name' => $job->order->farmer->name ?? 'Unknown Farmer',
            'buyer_name' => $job->order->buyer->name ?? 'Unknown Buyer',
            'transporter_id' => $job->transporter_id,
            'transporter_name' => $job->transporter ? $job->transporter->name : null,
            'estimated_pickup_date' => $job->order->delivery_date ? $job->order->delivery_date->format('Y-m-d') : null,
            'estimated_delivery_date' => $job->order->delivery_date ? $job->order->delivery_date->format('Y-m-d') : null,
            'created_at' => $job->created_at->format('Y-m-d\TH:i:s.u\Z'),
            'updated_at' => $job->updated_at->format('Y-m-d\TH:i:s.u\Z'),
        ];
    }
} 