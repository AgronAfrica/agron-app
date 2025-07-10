<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Crop;
use App\Models\User;

class CropSeeder extends Seeder
{
    public function run(): void
    {
        $farmer = User::where('role', 'farmer')->first();
        if (!$farmer) return;

        Crop::create([
            'name' => 'Maize',
            'description' => 'Fresh organic maize.',
            'price_per_kg' => 2.50,
            'quantity_available' => 100,
            'harvest_date' => now()->subDays(10),
            'location' => 'Farm Lane, Country',
            'category' => 'Grain',
            'status' => 'available',
            'user_id' => $farmer->id,
        ]);
        Crop::create([
            'name' => 'Tomatoes',
            'description' => 'Ripe red tomatoes.',
            'price_per_kg' => 1.80,
            'quantity_available' => 50,
            'harvest_date' => now()->subDays(5),
            'location' => 'Farm Lane, Country',
            'category' => 'Vegetable',
            'status' => 'available',
            'user_id' => $farmer->id,
        ]);
    }
}
