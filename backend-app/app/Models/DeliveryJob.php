<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeliveryJob extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'transporter_id',
        'pickup_location',
        'delivery_location',
        'status',
        'pickup_date',
        'delivery_date',
        'vehicle_type',
        'vehicle_number',
        'driver_name',
        'driver_phone',
        'estimated_duration',
        'actual_duration',
        'notes',
    ];

    protected $casts = [
        'pickup_date' => 'datetime',
        'delivery_date' => 'datetime',
        'estimated_duration' => 'integer',
        'actual_duration' => 'integer',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function transporter()
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }
} 