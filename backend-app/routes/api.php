<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CropController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\UserController;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Agron API is running',
        'timestamp' => now()
    ]);
});

Route::get('/test', function () {
    return response()->json([
        'message' => 'API is working!'
    ]);
});

// Authentication Routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

// Protected Routes
Route::middleware('auth:sanctum')->group(function () {
    // User Management
    Route::get('/user/profile', [UserController::class, 'profile']);
    Route::put('/user/profile', [UserController::class, 'updateProfile']);
    
    // Crops Management
    Route::get('/crops', [CropController::class, 'index']);
    Route::get('/crops/{crop}', [CropController::class, 'show']);
    Route::post('/crops', [CropController::class, 'store']);
    Route::put('/crops/{crop}', [CropController::class, 'update']);
    Route::delete('/crops/{crop}', [CropController::class, 'destroy']);
    
    // Orders Management
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::put('/orders/{order}', [OrderController::class, 'update']);
    Route::delete('/orders/{order}', [OrderController::class, 'destroy']);
    
    // Dashboard Data
    Route::get('/dashboard/stats', function () {
        return response()->json([
            'total_crops' => \App\Models\Crop::count(),
            'total_orders' => \App\Models\Order::count(),
            'recent_orders' => \App\Models\Order::latest()->take(5)->get(),
            'user_role' => auth()->user()->role
        ]);
    });
}); 