<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Order extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'crop_id',
        'buyer_id',
        'farmer_id',
        'quantity',
        'unit',
        'total_price',
        'currency',
        'status',
        'pickup_location',
        'delivery_location',
        'transporter_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'quantity' => 'float',
        'total_price' => 'float',
    ];

    /**
     * Order statuses
     */
    const STATUS_PENDING = 'pending';
    const STATUS_CONFIRMED = 'confirmed';
    const STATUS_IN_TRANSIT = 'in_transit';
    const STATUS_DELIVERED = 'delivered';
    const STATUS_CANCELLED = 'cancelled';

    /**
     * Get all statuses
     */
    public static function getStatuses(): array
    {
        return [
            self::STATUS_PENDING,
            self::STATUS_CONFIRMED,
            self::STATUS_IN_TRANSIT,
            self::STATUS_DELIVERED,
            self::STATUS_CANCELLED,
        ];
    }

    /**
     * Get status display name
     */
    public function getStatusDisplayName(): string
    {
        return match($this->status) {
            self::STATUS_PENDING => 'Pending',
            self::STATUS_CONFIRMED => 'Confirmed',
            self::STATUS_IN_TRANSIT => 'In Transit',
            self::STATUS_DELIVERED => 'Delivered',
            self::STATUS_CANCELLED => 'Cancelled',
            default => ucfirst($this->status),
        };
    }

    /**
     * Get status color
     */
    public function getStatusColor(): string
    {
        return match($this->status) {
            self::STATUS_PENDING => 'orange',
            self::STATUS_CONFIRMED => 'blue',
            self::STATUS_IN_TRANSIT => 'purple',
            self::STATUS_DELIVERED => 'green',
            self::STATUS_CANCELLED => 'red',
            default => 'gray',
        };
    }

    /**
     * Check if order is pending
     */
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * Check if order is confirmed
     */
    public function isConfirmed(): bool
    {
        return $this->status === self::STATUS_CONFIRMED;
    }

    /**
     * Check if order is in transit
     */
    public function isInTransit(): bool
    {
        return $this->status === self::STATUS_IN_TRANSIT;
    }

    /**
     * Check if order is delivered
     */
    public function isDelivered(): bool
    {
        return $this->status === self::STATUS_DELIVERED;
    }

    /**
     * Check if order is cancelled
     */
    public function isCancelled(): bool
    {
        return $this->status === self::STATUS_CANCELLED;
    }

    /**
     * Check if order can be cancelled
     */
    public function canBeCancelled(): bool
    {
        return in_array($this->status, [
            self::STATUS_PENDING,
            self::STATUS_CONFIRMED
        ]);
    }

    /**
     * Check if order can be confirmed
     */
    public function canBeConfirmed(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * Check if order can be shipped
     */
    public function canBeShipped(): bool
    {
        return $this->status === self::STATUS_CONFIRMED;
    }

    /**
     * Get crop relationship
     */
    public function crop(): BelongsTo
    {
        return $this->belongsTo(Crop::class);
    }

    /**
     * Get buyer relationship
     */
    public function buyer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'buyer_id');
    }

    /**
     * Get farmer relationship
     */
    public function farmer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'farmer_id');
    }

    /**
     * Get transporter relationship
     */
    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    /**
     * Get delivery job relationship
     */
    public function deliveryJob(): HasOne
    {
        return $this->hasOne(DeliveryJob::class);
    }

    /**
     * Get formatted total price
     */
    public function getFormattedTotalPrice(): string
    {
        return number_format($this->total_price, 2) . ' ' . strtoupper($this->currency);
    }

    /**
     * Get formatted quantity
     */
    public function getFormattedQuantity(): string
    {
        return number_format($this->quantity, 2) . ' ' . $this->unit;
    }

    /**
     * Get order number
     */
    public function getOrderNumber(): string
    {
        return 'ORD-' . str_pad($this->id, 6, '0', STR_PAD_LEFT);
    }

    /**
     * Scope to get orders by status
     */
    public function scopeByStatus($query, string $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope to get orders by buyer
     */
    public function scopeByBuyer($query, int $buyerId)
    {
        return $query->where('buyer_id', $buyerId);
    }

    /**
     * Scope to get orders by farmer
     */
    public function scopeByFarmer($query, int $farmerId)
    {
        return $query->where('farmer_id', $farmerId);
    }

    /**
     * Scope to get orders by transporter
     */
    public function scopeByTransporter($query, int $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }

    /**
     * Scope to get active orders
     */
    public function scopeActive($query)
    {
        return $query->whereIn('status', [
            self::STATUS_PENDING,
            self::STATUS_CONFIRMED,
            self::STATUS_IN_TRANSIT
        ]);
    }

    /**
     * Scope to get completed orders
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_DELIVERED);
    }

    /**
     * Scope to get cancelled orders
     */
    public function scopeCancelled($query)
    {
        return $query->where('status', self::STATUS_CANCELLED);
    }
} 