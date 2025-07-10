<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeliveryJob extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'order_id',
        'transporter_id',
        'status',
        'pickup_location',
        'delivery_location',
        'estimated_pickup_date',
        'estimated_delivery_date',
        'actual_pickup_date',
        'actual_delivery_date',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'estimated_pickup_date' => 'datetime',
        'estimated_delivery_date' => 'datetime',
        'actual_pickup_date' => 'datetime',
        'actual_delivery_date' => 'datetime',
    ];

    /**
     * Delivery job statuses
     */
    const STATUS_OPEN = 'open';
    const STATUS_ACCEPTED = 'accepted';
    const STATUS_PICKED_UP = 'picked_up';
    const STATUS_DELIVERED = 'delivered';
    const STATUS_CANCELLED = 'cancelled';

    /**
     * Get all statuses
     */
    public static function getStatuses(): array
    {
        return [
            self::STATUS_OPEN,
            self::STATUS_ACCEPTED,
            self::STATUS_PICKED_UP,
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
            self::STATUS_OPEN => 'Open',
            self::STATUS_ACCEPTED => 'Accepted',
            self::STATUS_PICKED_UP => 'Picked Up',
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
            self::STATUS_OPEN => 'blue',
            self::STATUS_ACCEPTED => 'orange',
            self::STATUS_PICKED_UP => 'purple',
            self::STATUS_DELIVERED => 'green',
            self::STATUS_CANCELLED => 'red',
            default => 'gray',
        };
    }

    /**
     * Check if job is open
     */
    public function isOpen(): bool
    {
        return $this->status === self::STATUS_OPEN;
    }

    /**
     * Check if job is accepted
     */
    public function isAccepted(): bool
    {
        return $this->status === self::STATUS_ACCEPTED;
    }

    /**
     * Check if job is picked up
     */
    public function isPickedUp(): bool
    {
        return $this->status === self::STATUS_PICKED_UP;
    }

    /**
     * Check if job is delivered
     */
    public function isDelivered(): bool
    {
        return $this->status === self::STATUS_DELIVERED;
    }

    /**
     * Check if job is cancelled
     */
    public function isCancelled(): bool
    {
        return $this->status === self::STATUS_CANCELLED;
    }

    /**
     * Check if job can be accepted
     */
    public function canBeAccepted(): bool
    {
        return $this->status === self::STATUS_OPEN;
    }

    /**
     * Check if job can be picked up
     */
    public function canBePickedUp(): bool
    {
        return $this->status === self::STATUS_ACCEPTED;
    }

    /**
     * Check if job can be delivered
     */
    public function canBeDelivered(): bool
    {
        return $this->status === self::STATUS_PICKED_UP;
    }

    /**
     * Check if job can be cancelled
     */
    public function canBeCancelled(): bool
    {
        return in_array($this->status, [
            self::STATUS_OPEN,
            self::STATUS_ACCEPTED
        ]);
    }

    /**
     * Get order relationship
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Get transporter relationship
     */
    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    /**
     * Get job number
     */
    public function getJobNumber(): string
    {
        return 'JOB-' . str_pad($this->id, 6, '0', STR_PAD_LEFT);
    }

    /**
     * Get formatted estimated pickup date
     */
    public function getFormattedEstimatedPickupDate(): ?string
    {
        return $this->estimated_pickup_date?->format('M d, Y H:i');
    }

    /**
     * Get formatted estimated delivery date
     */
    public function getFormattedEstimatedDeliveryDate(): ?string
    {
        return $this->estimated_delivery_date?->format('M d, Y H:i');
    }

    /**
     * Get formatted actual pickup date
     */
    public function getFormattedActualPickupDate(): ?string
    {
        return $this->actual_pickup_date?->format('M d, Y H:i');
    }

    /**
     * Get formatted actual delivery date
     */
    public function getFormattedActualDeliveryDate(): ?string
    {
        return $this->actual_delivery_date?->format('M d, Y H:i');
    }

    /**
     * Accept the job
     */
    public function accept(int $transporterId): bool
    {
        if (!$this->canBeAccepted()) {
            return false;
        }

        $this->transporter_id = $transporterId;
        $this->status = self::STATUS_ACCEPTED;
        $this->estimated_pickup_date = now()->addHours(2);
        $this->estimated_delivery_date = now()->addHours(6);
        
        return $this->save();
    }

    /**
     * Mark as picked up
     */
    public function markAsPickedUp(): bool
    {
        if (!$this->canBePickedUp()) {
            return false;
        }

        $this->status = self::STATUS_PICKED_UP;
        $this->actual_pickup_date = now();
        
        return $this->save();
    }

    /**
     * Mark as delivered
     */
    public function markAsDelivered(): bool
    {
        if (!$this->canBeDelivered()) {
            return false;
        }

        $this->status = self::STATUS_DELIVERED;
        $this->actual_delivery_date = now();
        
        return $this->save();
    }

    /**
     * Cancel the job
     */
    public function cancel(): bool
    {
        if (!$this->canBeCancelled()) {
            return false;
        }

        $this->status = self::STATUS_CANCELLED;
        
        return $this->save();
    }

    /**
     * Scope to get open jobs
     */
    public function scopeOpen($query)
    {
        return $query->where('status', self::STATUS_OPEN);
    }

    /**
     * Scope to get accepted jobs
     */
    public function scopeAccepted($query)
    {
        return $query->where('status', self::STATUS_ACCEPTED);
    }

    /**
     * Scope to get active jobs
     */
    public function scopeActive($query)
    {
        return $query->whereIn('status', [
            self::STATUS_ACCEPTED,
            self::STATUS_PICKED_UP
        ]);
    }

    /**
     * Scope to get completed jobs
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_DELIVERED);
    }

    /**
     * Scope to get jobs by transporter
     */
    public function scopeByTransporter($query, int $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }

    /**
     * Scope to get jobs by order
     */
    public function scopeByOrder($query, int $orderId)
    {
        return $query->where('order_id', $orderId);
    }
} 