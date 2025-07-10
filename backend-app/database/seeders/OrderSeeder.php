<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\User;
use App\Models\Crop;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        $buyer = User::where('role', 'buyer')->first();
        $maize = Crop::where('name', 'Maize')->first();
        $tomatoes = Crop::where('name', 'Tomatoes')->first();
        if (!$buyer || !$maize || !$tomatoes) return;

        Order::create([
            'user_id' => $buyer->id,
            'crop_id' => $maize->id,
            'quantity' => 10,
            'total_price' => 25.00,
            'status' => 'pending',
            'delivery_address' => 'Market Street, City',
            'delivery_date' => now()->addDays(2),
            'payment_method' => 'cash',
            'notes' => 'Please deliver in the morning.',
        ]);
        Order::create([
            'user_id' => $buyer->id,
            'crop_id' => $tomatoes->id,
            'quantity' => 5,
            'total_price' => 9.00,
            'status' => 'pending',
            'delivery_address' => 'Market Street, City',
            'delivery_date' => now()->addDays(3),
            'payment_method' => 'card',
            'notes' => null,
        ]);
    }
}
