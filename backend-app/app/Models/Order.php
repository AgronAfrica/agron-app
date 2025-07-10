<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'crop_id',
        'quantity',
        'total_price',
        'status',
        'delivery_address',
        'delivery_date',
        'payment_method',
        'notes',
    ];

    protected $casts = [
        'delivery_date' => 'date',
        'total_price' => 'decimal:2',
        'quantity' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function crop()
    {
        return $this->belongsTo(Crop::class);
    }

    public function deliveryJob()
    {
        return $this->hasOne(DeliveryJob::class);
    }
} 