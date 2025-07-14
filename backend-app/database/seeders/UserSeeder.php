<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'farmer@example.com'],
            [
                'name' => 'Farmer Joe',
                'password' => Hash::make('password123'),
                'role' => 'farmer',
                'phone' => '1234567890',
                'address' => 'Farm Lane, Country',
            ]
        );
        User::updateOrCreate(
            ['email' => 'buyer@example.com'],
            [
                'name' => 'Buyer Bob',
                'password' => Hash::make('password123'),
                'role' => 'buyer',
                'phone' => '2345678901',
                'address' => 'Market Street, City',
            ]
        );
        User::updateOrCreate(
            ['email' => 'transporter@example.com'],
            [
                'name' => 'Transporter Tom',
                'password' => Hash::make('password123'),
                'role' => 'transporter',
                'phone' => '3456789012',
                'address' => 'Logistics Ave, Town',
            ]
        );
    }
}
