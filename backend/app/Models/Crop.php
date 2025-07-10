<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Crop extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'farmer_id',
        'name',
        'type',
        'quantity',
        'unit',
        'price',
        'currency',
        'location',
        'availability_date',
        'description',
        'status',
        'image_path',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'quantity' => 'float',
        'price' => 'float',
        'availability_date' => 'date',
    ];

    /**
     * Crop statuses
     */
    const STATUS_AVAILABLE = 'available';
    const STATUS_SOLD = 'sold';
    const STATUS_RESERVED = 'reserved';

    /**
     * Get all statuses
     */
    public static function getStatuses(): array
    {
        return [
            self::STATUS_AVAILABLE,
            self::STATUS_SOLD,
            self::STATUS_RESERVED,
        ];
    }

    /**
     * Get status display name
     */
    public function getStatusDisplayName(): string
    {
        return ucfirst($this->status);
    }

    /**
     * Check if crop is available
     */
    public function isAvailable(): bool
    {
        return $this->status === self::STATUS_AVAILABLE;
    }

    /**
     * Check if crop is sold
     */
    public function isSold(): bool
    {
        return $this->status === self::STATUS_SOLD;
    }

    /**
     * Check if crop is reserved
     */
    public function isReserved(): bool
    {
        return $this->status === self::STATUS_RESERVED;
    }

    /**
     * Get farmer relationship
     */
    public function farmer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'farmer_id');
    }

    /**
     * Get orders for this crop
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Get active orders for this crop
     */
    public function activeOrders(): HasMany
    {
        return $this->orders()->whereIn('status', [
            Order::STATUS_PENDING,
            Order::STATUS_CONFIRMED,
            Order::STATUS_IN_TRANSIT
        ]);
    }

    /**
     * Get total price for given quantity
     */
    public function getTotalPrice(float $quantity): float
    {
        return $this->price * $quantity;
    }

    /**
     * Get formatted price
     */
    public function getFormattedPrice(): string
    {
        return number_format($this->price, 2) . ' ' . strtoupper($this->currency);
    }

    /**
     * Get formatted quantity
     */
    public function getFormattedQuantity(): string
    {
        return number_format($this->quantity, 2) . ' ' . $this->unit;
    }

    /**
     * Get image URL
     */
    public function getImageUrl(): ?string
    {
        if (!$this->image_path) {
            return null;
        }

        return asset('storage/' . $this->image_path);
    }

    /**
     * Scope to get available crops
     */
    public function scopeAvailable($query)
    {
        return $query->where('status', self::STATUS_AVAILABLE);
    }

    /**
     * Scope to get crops by type
     */
    public function scopeByType($query, string $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Scope to get crops by region
     */
    public function scopeByRegion($query, string $region)
    {
        return $query->where('location', 'like', "%{$region}%");
    }

    /**
     * Scope to get crops by farmer
     */
    public function scopeByFarmer($query, int $farmerId)
    {
        return $query->where('farmer_id', $farmerId);
    }

    /**
     * Scope to get crops with price range
     */
    public function scopePriceRange($query, float $minPrice, float $maxPrice)
    {
        return $query->whereBetween('price', [$minPrice, $maxPrice]);
    }

    /**
     * Scope to get crops available by date
     */
    public function scopeAvailableByDate($query, string $date)
    {
        return $query->where('availability_date', '<=', $date);
    }
} 