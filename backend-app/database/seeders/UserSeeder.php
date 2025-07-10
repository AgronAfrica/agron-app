<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Farmer Joe',
            'email' => 'farmer@example.com',
            'password' => Hash::make('password123'),
            'role' => 'farmer',
            'phone' => '1234567890',
            'address' => 'Farm Lane, Country',
        ]);
        User::create([
            'name' => 'Buyer Bob',
            'email' => 'buyer@example.com',
            'password' => Hash::make('password123'),
            'role' => 'buyer',
            'phone' => '2345678901',
            'address' => 'Market Street, City',
        ]);
        User::create([
            'name' => 'Transporter Tom',
            'email' => 'transporter@example.com',
            'password' => Hash::make('password123'),
            'role' => 'transporter',
            'phone' => '3456789012',
            'address' => 'Logistics Ave, Town',
        ]);
    }
}
