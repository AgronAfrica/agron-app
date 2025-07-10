<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create sample farmers
        $farmer1 = User::create([
            'name' => 'John Farmer',
            'email' => 'farmer@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348012345678',
            'role' => 'farmer',
            'location' => 'Lagos, Nigeria',
        ]);

        $farmer2 = User::create([
            'name' => 'Sarah Okechukwu',
            'email' => 'sarah@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348023456789',
            'role' => 'farmer',
            'location' => 'Kano, Nigeria',
        ]);

        $farmer3 = User::create([
            'name' => 'Mohammed Bello',
            'email' => 'mohammed@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348034567890',
            'role' => 'farmer',
            'location' => 'Kaduna, Nigeria',
        ]);

        // Create sample buyers
        $buyer1 = User::create([
            'name' => 'Jane Buyer',
            'email' => 'buyer@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348098765432',
            'role' => 'buyer',
            'location' => 'Abuja, Nigeria',
        ]);

        $buyer2 = User::create([
            'name' => 'David Johnson',
            'email' => 'david@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348087654321',
            'role' => 'buyer',
            'location' => 'Port Harcourt, Nigeria',
        ]);

        $buyer3 = User::create([
            'name' => 'Fatima Hassan',
            'email' => 'fatima@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348076543210',
            'role' => 'buyer',
            'location' => 'Ibadan, Nigeria',
        ]);

        // Create sample transporters
        $transporter1 = User::create([
            'name' => 'Mike Transporter',
            'email' => 'transporter@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348055555555',
            'role' => 'transporter',
            'location' => 'Kano, Nigeria',
        ]);

        $transporter2 = User::create([
            'name' => 'Aisha Yusuf',
            'email' => 'aisha@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348066666666',
            'role' => 'transporter',
            'location' => 'Lagos, Nigeria',
        ]);

        $transporter3 = User::create([
            'name' => 'Chukwudi Okonkwo',
            'email' => 'chukwudi@agron.farm',
            'password' => Hash::make('password'),
            'phone' => '+2348077777777',
            'role' => 'transporter',
            'location' => 'Enugu, Nigeria',
        ]);

        $this->command->info('Sample users created successfully!');
        $this->command->info('Farmers: farmer@agron.farm, sarah@agron.farm, mohammed@agron.farm');
        $this->command->info('Buyers: buyer@agron.farm, david@agron.farm, fatima@agron.farm');
        $this->command->info('Transporters: transporter@agron.farm, aisha@agron.farm, chukwudi@agron.farm');
        $this->command->info('All users password: password');
    }
} 