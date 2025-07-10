<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'role',
        'location',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * User roles
     */
    const ROLE_FARMER = 'farmer';
    const ROLE_BUYER = 'buyer';
    const ROLE_TRANSPORTER = 'transporter';

    /**
     * Get all roles
     */
    public static function getRoles(): array
    {
        return [
            self::ROLE_FARMER,
            self::ROLE_BUYER,
            self::ROLE_TRANSPORTER,
        ];
    }

    /**
     * Check if user is a farmer
     */
    public function isFarmer(): bool
    {
        return $this->role === self::ROLE_FARMER;
    }

    /**
     * Check if user is a buyer
     */
    public function isBuyer(): bool
    {
        return $this->role === self::ROLE_BUYER;
    }

    /**
     * Check if user is a transporter
     */
    public function isTransporter(): bool
    {
        return $this->role === self::ROLE_TRANSPORTER;
    }

    /**
     * Get role display name
     */
    public function getRoleDisplayName(): string
    {
        return ucfirst($this->role);
    }

    /**
     * Get crops for farmer
     */
    public function crops(): HasMany
    {
        return $this->hasMany(Crop::class, 'farmer_id');
    }

    /**
     * Get orders as buyer
     */
    public function buyerOrders(): HasMany
    {
        return $this->hasMany(Order::class, 'buyer_id');
    }

    /**
     * Get orders as farmer
     */
    public function farmerOrders(): HasMany
    {
        return $this->hasMany(Order::class, 'farmer_id');
    }

    /**
     * Get delivery jobs as transporter
     */
    public function deliveryJobs(): HasMany
    {
        return $this->hasMany(DeliveryJob::class, 'transporter_id');
    }

    /**
     * Get user's active crops count
     */
    public function getActiveCropsCount(): int
    {
        return $this->crops()->where('status', Crop::STATUS_AVAILABLE)->count();
    }

    /**
     * Get user's total sales
     */
    public function getTotalSales(): float
    {
        return $this->farmerOrders()
            ->where('status', Order::STATUS_DELIVERED)
            ->sum('total_price');
    }

    /**
     * Get user's pending orders count
     */
    public function getPendingOrdersCount(): int
    {
        return $this->buyerOrders()
            ->whereIn('status', [Order::STATUS_PENDING, Order::STATUS_CONFIRMED])
            ->count();
    }

    /**
     * Get user's active delivery jobs count
     */
    public function getActiveDeliveryJobsCount(): int
    {
        return $this->deliveryJobs()
            ->whereIn('status', [DeliveryJob::STATUS_ACCEPTED, DeliveryJob::STATUS_PICKED_UP])
            ->count();
    }
} 