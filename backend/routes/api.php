<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CropController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\DeliveryJobController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Authentication
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::put('/change-password', [AuthController::class, 'changePassword']);
    Route::get('/statistics', [AuthController::class, 'statistics']);

    // Crops
    Route::get('/crops', [CropController::class, 'index']);
    Route::get('/crops/types', [CropController::class, 'types']);
    Route::get('/crops/regions', [CropController::class, 'regions']);
    Route::get('/crops/{crop}', [CropController::class, 'show']);
    Route::post('/crops', [CropController::class, 'store']);
    Route::put('/crops/{crop}', [CropController::class, 'update']);
    Route::delete('/crops/{crop}', [CropController::class, 'destroy']);
    Route::patch('/crops/{crop}/status', [CropController::class, 'updateStatus']);
    Route::get('/crops/statistics', [CropController::class, 'statistics']);

    // Orders
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::post('/orders/{order}/cancel', [OrderController::class, 'cancel']);
    Route::get('/orders/statistics', [OrderController::class, 'statistics']);

    // Delivery Jobs (Transporters only)
    Route::prefix('jobs')->group(function () {
        Route::get('/', [DeliveryJobController::class, 'index']);
        Route::get('/available', [DeliveryJobController::class, 'availableJobs']);
        Route::get('/my-jobs', [DeliveryJobController::class, 'myJobs']);
        Route::get('/{job}', [DeliveryJobController::class, 'show']);
        Route::post('/accept', [DeliveryJobController::class, 'accept']);
        Route::patch('/{job}/pickup', [DeliveryJobController::class, 'markPickedUp']);
        Route::patch('/{job}/delivered', [DeliveryJobController::class, 'markDelivered']);
        Route::post('/{job}/cancel', [DeliveryJobController::class, 'cancel']);
        Route::get('/statistics', [DeliveryJobController::class, 'statistics']);
    });
});

// Health check route
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'version' => '1.0.0'
    ]);
}); 