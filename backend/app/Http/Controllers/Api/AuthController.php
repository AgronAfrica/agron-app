<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
            'role' => $request->role,
            'location' => $request->location,
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
            'message' => 'User registered successfully'
        ], 201);
    }

    /**
     * Login user
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
            'message' => 'Login successful'
        ]);
    }

    /**
     * Get authenticated user
     */
    public function user(Request $request): JsonResponse
    {
        return response()->json([
            'user' => new UserResource($request->user())
        ]);
    }

    /**
     * Logout user
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|nullable|string|max:20',
            'location' => 'sometimes|nullable|string|max:255',
        ]);

        $user->update($request->only(['name', 'phone', 'location']));

        return response()->json([
            'user' => new UserResource($user),
            'message' => 'Profile updated successfully'
        ]);
    }

    /**
     * Change password
     */
    public function changePassword(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'message' => 'Password changed successfully'
        ]);
    }

    /**
     * Get user statistics based on role
     */
    public function statistics(Request $request): JsonResponse
    {
        $user = $request->user();
        $statistics = [];

        switch ($user->role) {
            case User::ROLE_FARMER:
                $statistics = [
                    'active_crops' => $user->getActiveCropsCount(),
                    'total_sales' => $user->getTotalSales(),
                    'total_orders' => $user->farmerOrders()->count(),
                    'pending_orders' => $user->farmerOrders()->where('status', 'pending')->count(),
                ];
                break;

            case User::ROLE_BUYER:
                $statistics = [
                    'total_orders' => $user->buyerOrders()->count(),
                    'pending_orders' => $user->getPendingOrdersCount(),
                    'completed_orders' => $user->buyerOrders()->where('status', 'delivered')->count(),
                    'total_spent' => $user->buyerOrders()->where('status', 'delivered')->sum('total_price'),
                ];
                break;

            case User::ROLE_TRANSPORTER:
                $statistics = [
                    'active_jobs' => $user->getActiveDeliveryJobsCount(),
                    'total_jobs' => $user->deliveryJobs()->count(),
                    'completed_jobs' => $user->deliveryJobs()->where('status', 'delivered')->count(),
                    'total_earnings' => 0, // Calculate based on your pricing model
                ];
                break;
        }

        return response()->json([
            'statistics' => $statistics
        ]);
    }
} 