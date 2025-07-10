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
        $query = DeliveryJob::with(['order.crop', 'order.buyer', 'order.farmer', 'transporter']);

        // Filter by status
        if ($request->has('status')) {
            $query->byStatus($request->status);
        }

        // Get jobs for specific transporter
        if (Auth::user()->isTransporter()) {
            $query->forTransporter(Auth::id());
        }

        $jobs = $query->latest()->get();

        // Transform data for iOS app
        $jobs = $jobs->map(function ($job) {
            return [
                'id' => $job->id,
                'order_id' => $job->order_id,
                'order_number' => $job->order_number,
                'pickup_location' => $job->pickup_location,
                'delivery_location' => $job->delivery_location,
                'crop_name' => $job->crop_name,
                'quantity' => (float) $job->quantity,
                'unit' => $job->unit,
                'status' => $job->status,
                'farmer_name' => $job->farmer_name,
                'buyer_name' => $job->buyer_name,
                'transporter_id' => $job->transporter_id,
                'transporter_name' => $job->transporter_name,
                'estimated_pickup_date' => $job->estimated_pickup_date ? $job->estimated_pickup_date->format('Y-m-d') : null,
                'estimated_delivery_date' => $job->estimated_delivery_date ? $job->estimated_delivery_date->format('Y-m-d') : null,
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

        $job = DeliveryJob::findOrFail($request->job_id);

        // Check if job is open
        if (!$job->canBeAccepted()) {
            return response()->json(['message' => 'Job is not available for acceptance'], 400);
        }

        // Accept the job
        if ($job->accept(Auth::id())) {
            return response()->json($job);
        }

        return response()->json(['message' => 'Failed to accept job'], 400);
    }

    /**
     * Mark job as picked up.
     */
    public function markPickedUp(DeliveryJob $job)
    {
        // Check if user is the transporter for this job
        if ($job->transporter_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($job->markPickedUp()) {
            return response()->json($job);
        }

        return response()->json(['message' => 'Failed to mark as picked up'], 400);
    }

    /**
     * Mark job as delivered.
     */
    public function markDelivered(DeliveryJob $job)
    {
        // Check if user is the transporter for this job
        if ($job->transporter_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($job->markDelivered()) {
            return response()->json($job);
        }

        return response()->json(['message' => 'Failed to mark as delivered'], 400);
    }

    /**
     * Display the specified delivery job.
     */
    public function show(DeliveryJob $job)
    {
        // Check if user has access to this job
        if ($job->transporter_id && $job->transporter_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $job->load(['order.crop', 'order.buyer', 'order.farmer', 'transporter']);

        return response()->json([
            'id' => $job->id,
            'order_id' => $job->order_id,
            'order_number' => $job->order_number,
            'pickup_location' => $job->pickup_location,
            'delivery_location' => $job->delivery_location,
            'crop_name' => $job->crop_name,
            'quantity' => (float) $job->quantity,
            'unit' => $job->unit,
            'status' => $job->status,
            'farmer_name' => $job->farmer_name,
            'buyer_name' => $job->buyer_name,
            'transporter_id' => $job->transporter_id,
            'transporter_name' => $job->transporter_name,
            'estimated_pickup_date' => $job->estimated_pickup_date ? $job->estimated_pickup_date->format('Y-m-d') : null,
            'estimated_delivery_date' => $job->estimated_delivery_date ? $job->estimated_delivery_date->format('Y-m-d') : null,
            'created_at' => $job->created_at->format('Y-m-d\TH:i:s.u\Z'),
            'updated_at' => $job->updated_at->format('Y-m-d\TH:i:s.u\Z'),
        ]);
    }

    /**
     * Update delivery job.
     */
    public function update(Request $request, DeliveryJob $job)
    {
        // Check if user is the transporter for this job
        if ($job->transporter_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'estimated_pickup_date' => 'sometimes|date',
            'estimated_delivery_date' => 'sometimes|date',
        ]);

        $job->update($request->only(['estimated_pickup_date', 'estimated_delivery_date']));

        return response()->json($job);
    }
} 