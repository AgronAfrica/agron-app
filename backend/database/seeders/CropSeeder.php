<?php

namespace Database\Seeders;

use App\Models\Crop;
use App\Models\User;
use Illuminate\Database\Seeder;

class CropSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $farmers = User::where('role', 'farmer')->get();

        if ($farmers->isEmpty()) {
            $this->command->warn('No farmers found. Please run UserSeeder first.');
            return;
        }

        // Sample crops for the first farmer
        $farmer1 = $farmers->first();
        
        Crop::create([
            'name' => 'Fresh Cassava',
            'type' => 'Cassava',
            'quantity' => 100.0,
            'unit' => 'kg',
            'price' => 5000.0,
            'currency' => 'NGN',
            'location' => 'Lagos, Nigeria',
            'availability_date' => '2025-01-15',
            'description' => 'Fresh cassava from local farm, perfect for garri production',
            'farmer_id' => $farmer1->id,
            'status' => 'available',
        ]);

        Crop::create([
            'name' => 'Premium Rice',
            'type' => 'Rice',
            'quantity' => 50.0,
            'unit' => 'bags',
            'price' => 15000.0,
            'currency' => 'NGN',
            'location' => 'Kano, Nigeria',
            'availability_date' => '2025-01-20',
            'description' => 'High-quality rice from northern farms, perfect for local consumption',
            'farmer_id' => $farmer1->id,
            'status' => 'available',
        ]);

        Crop::create([
            'name' => 'Sweet Corn',
            'type' => 'Maize',
            'quantity' => 200.0,
            'unit' => 'kg',
            'price' => 3000.0,
            'currency' => 'NGN',
            'location' => 'Oyo, Nigeria',
            'availability_date' => '2025-01-25',
            'description' => 'Fresh sweet corn from southwestern farms, great for roasting',
            'farmer_id' => $farmer1->id,
            'status' => 'available',
        ]);

        Crop::create([
            'name' => 'Fresh Tomatoes',
            'type' => 'Tomato',
            'quantity' => 75.0,
            'unit' => 'kg',
            'price' => 8000.0,
            'currency' => 'NGN',
            'location' => 'Kaduna, Nigeria',
            'availability_date' => '2025-01-30',
            'description' => 'Ripe tomatoes from northern farms, perfect for cooking',
            'farmer_id' => $farmer1->id,
            'status' => 'available',
        ]);

        Crop::create([
            'name' => 'Hot Peppers',
            'type' => 'Pepper',
            'quantity' => 25.0,
            'unit' => 'kg',
            'price' => 12000.0,
            'currency' => 'NGN',
            'location' => 'Cross River, Nigeria',
            'availability_date' => '2025-02-05',
            'description' => 'Spicy peppers from southeastern farms, great for pepper soup',
            'farmer_id' => $farmer1->id,
            'status' => 'available',
        ]);

        // Sample crops for the second farmer
        if ($farmers->count() > 1) {
            $farmer2 = $farmers[1];
            
            Crop::create([
                'name' => 'Yam Tubers',
                'type' => 'Yam',
                'quantity' => 80.0,
                'unit' => 'kg',
                'price' => 6000.0,
                'currency' => 'NGN',
                'location' => 'Kano, Nigeria',
                'availability_date' => '2025-01-18',
                'description' => 'Fresh yam tubers from northern farms, perfect for pounded yam',
                'farmer_id' => $farmer2->id,
                'status' => 'available',
            ]);

            Crop::create([
                'name' => 'Plantain',
                'type' => 'Plantain',
                'quantity' => 60.0,
                'unit' => 'kg',
                'price' => 4000.0,
                'currency' => 'NGN',
                'location' => 'Kaduna, Nigeria',
                'availability_date' => '2025-01-22',
                'description' => 'Ripe plantains from northern farms, great for cooking',
                'farmer_id' => $farmer2->id,
                'status' => 'available',
            ]);

            Crop::create([
                'name' => 'Fresh Beans',
                'type' => 'Beans',
                'quantity' => 40.0,
                'unit' => 'kg',
                'price' => 7000.0,
                'currency' => 'NGN',
                'location' => 'Kaduna, Nigeria',
                'availability_date' => '2025-01-28',
                'description' => 'Fresh beans from northern farms, perfect for beans porridge',
                'farmer_id' => $farmer2->id,
                'status' => 'available',
            ]);
        }

        // Sample crops for the third farmer
        if ($farmers->count() > 2) {
            $farmer3 = $farmers[2];
            
            Crop::create([
                'name' => 'Cocoa Beans',
                'type' => 'Cocoa',
                'quantity' => 30.0,
                'unit' => 'kg',
                'price' => 25000.0,
                'currency' => 'NGN',
                'location' => 'Kaduna, Nigeria',
                'availability_date' => '2025-02-01',
                'description' => 'Premium cocoa beans from northern farms, great for chocolate production',
                'farmer_id' => $farmer3->id,
                'status' => 'available',
            ]);

            Crop::create([
                'name' => 'Groundnuts',
                'type' => 'Groundnut',
                'quantity' => 45.0,
                'unit' => 'kg',
                'price' => 9000.0,
                'currency' => 'NGN',
                'location' => 'Kaduna, Nigeria',
                'availability_date' => '2025-02-03',
                'description' => 'Fresh groundnuts from northern farms, perfect for groundnut soup',
                'farmer_id' => $farmer3->id,
                'status' => 'available',
            ]);
        }

        $this->command->info('Sample crops created successfully!');
        $this->command->info('Total crops created: ' . Crop::count());
    }
} 