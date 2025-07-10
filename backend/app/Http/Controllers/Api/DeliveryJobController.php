<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DeliveryJobResource;
use App\Models\DeliveryJob;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeliveryJobController extends Controller
{
    /**
     * Get available delivery jobs (transporters only)
     */
    public function index(Request $request): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can view delivery jobs'
            ], 403);
        }

        $query = DeliveryJob::with(['order.crop', 'order.farmer', 'order.buyer', 'transporter']);

        // Filter by status
        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        // Show open jobs for transporters
        if ($request->has('available') && $request->available) {
            $query->open();
        }

        // Show transporter's accepted jobs
        if ($request->has('my_jobs') && $request->my_jobs) {
            $query->byTransporter($request->user()->id);
        }

        $jobs = $query->latest()->paginate(20);

        return response()->json([
            'jobs' => DeliveryJobResource::collection($jobs),
            'pagination' => [
                'current_page' => $jobs->currentPage(),
                'last_page' => $jobs->lastPage(),
                'per_page' => $jobs->perPage(),
                'total' => $jobs->total(),
            ]
        ]);
    }

    /**
     * Get a specific delivery job
     */
    public function show(DeliveryJob $job): JsonResponse
    {
        return response()->json([
            'job' => new DeliveryJobResource($job->load(['order.crop', 'order.farmer', 'order.buyer', 'transporter']))
        ]);
    }

    /**
     * Accept a delivery job (transporters only)
     */
    public function accept(Request $request): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can accept delivery jobs'
            ], 403);
        }

        $request->validate([
            'job_id' => 'required|exists:delivery_jobs,id'
        ]);

        $job = DeliveryJob::findOrFail($request->job_id);

        if (!$job->canBeAccepted()) {
            return response()->json([
                'message' => 'Job cannot be accepted'
            ], 400);
        }

        if ($job->accept($request->user()->id)) {
            // Update order with transporter
            $job->order->update(['transporter_id' => $request->user()->id]);

            return response()->json([
                'job' => new DeliveryJobResource($job->load(['order.crop', 'order.farmer', 'order.buyer', 'transporter'])),
                'message' => 'Job accepted successfully'
            ]);
        }

        return response()->json([
            'message' => 'Failed to accept job'
        ], 400);
    }

    /**
     * Mark job as picked up (transporters only)
     */
    public function markPickedUp(Request $request, DeliveryJob $job): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can update job status'
            ], 403);
        }

        if ($job->transporter_id !== $request->user()->id) {
            return response()->json([
                'message' => 'You can only update jobs you accepted'
            ], 403);
        }

        if (!$job->canBePickedUp()) {
            return response()->json([
                'message' => 'Job cannot be marked as picked up'
            ], 400);
        }

        if ($job->markAsPickedUp()) {
            // Update order status to in transit
            $job->order->update(['status' => Order::STATUS_IN_TRANSIT]);

            return response()->json([
                'job' => new DeliveryJobResource($job->load(['order.crop', 'order.farmer', 'order.buyer', 'transporter'])),
                'message' => 'Job marked as picked up successfully'
            ]);
        }

        return response()->json([
            'message' => 'Failed to update job status'
        ], 400);
    }

    /**
     * Mark job as delivered (transporters only)
     */
    public function markDelivered(Request $request, DeliveryJob $job): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can update job status'
            ], 403);
        }

        if ($job->transporter_id !== $request->user()->id) {
            return response()->json([
                'message' => 'You can only update jobs you accepted'
            ], 403);
        }

        if (!$job->canBeDelivered()) {
            return response()->json([
                'message' => 'Job cannot be marked as delivered'
            ], 400);
        }

        if ($job->markAsDelivered()) {
            // Update order status to delivered
            $job->order->update(['status' => Order::STATUS_DELIVERED]);

            return response()->json([
                'job' => new DeliveryJobResource($job->load(['order.crop', 'order.farmer', 'order.buyer', 'transporter'])),
                'message' => 'Job marked as delivered successfully'
            ]);
        }

        return response()->json([
            'message' => 'Failed to update job status'
        ], 400);
    }

    /**
     * Cancel delivery job (transporters only)
     */
    public function cancel(Request $request, DeliveryJob $job): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can cancel delivery jobs'
            ], 403);
        }

        if ($job->transporter_id !== $request->user()->id) {
            return response()->json([
                'message' => 'You can only cancel jobs you accepted'
            ], 403);
        }

        if (!$job->canBeCancelled()) {
            return response()->json([
                'message' => 'Job cannot be cancelled at this stage'
            ], 400);
        }

        if ($job->cancel()) {
            // Remove transporter from order
            $job->order->update(['transporter_id' => null]);

            return response()->json([
                'job' => new DeliveryJobResource($job->load(['order.crop', 'order.farmer', 'order.buyer', 'transporter'])),
                'message' => 'Job cancelled successfully'
            ]);
        }

        return response()->json([
            'message' => 'Failed to cancel job'
        ], 400);
    }

    /**
     * Get transporter's job statistics
     */
    public function statistics(Request $request): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can view job statistics'
            ], 403);
        }

        $transporter = $request->user();

        $statistics = [
            'total_jobs' => $transporter->deliveryJobs()->count(),
            'open_jobs' => $transporter->deliveryJobs()->where('status', DeliveryJob::STATUS_OPEN)->count(),
            'accepted_jobs' => $transporter->deliveryJobs()->where('status', DeliveryJob::STATUS_ACCEPTED)->count(),
            'picked_up_jobs' => $transporter->deliveryJobs()->where('status', DeliveryJob::STATUS_PICKED_UP)->count(),
            'delivered_jobs' => $transporter->deliveryJobs()->where('status', DeliveryJob::STATUS_DELIVERED)->count(),
            'cancelled_jobs' => $transporter->deliveryJobs()->where('status', DeliveryJob::STATUS_CANCELLED)->count(),
            'active_jobs' => $transporter->getActiveDeliveryJobsCount(),
        ];

        return response()->json([
            'statistics' => $statistics
        ]);
    }

    /**
     * Get available jobs for transporters
     */
    public function availableJobs(Request $request): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can view available jobs'
            ], 403);
        }

        $jobs = DeliveryJob::with(['order.crop', 'order.farmer', 'order.buyer'])
            ->open()
            ->latest()
            ->paginate(20);

        return response()->json([
            'jobs' => DeliveryJobResource::collection($jobs),
            'pagination' => [
                'current_page' => $jobs->currentPage(),
                'last_page' => $jobs->lastPage(),
                'per_page' => $jobs->perPage(),
                'total' => $jobs->total(),
            ]
        ]);
    }

    /**
     * Get transporter's active jobs
     */
    public function myJobs(Request $request): JsonResponse
    {
        if (!$request->user()->isTransporter()) {
            return response()->json([
                'message' => 'Only transporters can view their jobs'
            ], 403);
        }

        $jobs = DeliveryJob::with(['order.crop', 'order.farmer', 'order.buyer'])
            ->byTransporter($request->user()->id)
            ->whereIn('status', [DeliveryJob::STATUS_ACCEPTED, DeliveryJob::STATUS_PICKED_UP])
            ->latest()
            ->paginate(20);

        return response()->json([
            'jobs' => DeliveryJobResource::collection($jobs),
            'pagination' => [
                'current_page' => $jobs->currentPage(),
                'last_page' => $jobs->lastPage(),
                'per_page' => $jobs->perPage(),
                'total' => $jobs->total(),
            ]
        ]);
    }
} 