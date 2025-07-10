<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'phone',
        'address',
        'profile_image',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function crops()
    {
        return $this->hasMany(Crop::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function isFarmer()
    {
        return $this->role === 'farmer';
    }

    public function isBuyer()
    {
        return $this->role === 'buyer';
    }

    public function isTransporter()
    {
        return $this->role === 'transporter';
    }
}
