<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Crop extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'price_per_kg',
        'quantity_available',
        'harvest_date',
        'location',
        'image',
        'user_id',
        'category',
        'status',
    ];

    protected $casts = [
        'harvest_date' => 'date',
        'price_per_kg' => 'decimal:2',
        'quantity_available' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
} 