<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->getOrderNumber(),
            'crop' => [
                'id' => $this->crop->id,
                'name' => $this->crop->name,
                'type' => $this->crop->type,
            ],
            'buyer' => [
                'id' => $this->buyer->id,
                'name' => $this->buyer->name,
            ],
            'farmer' => [
                'id' => $this->farmer->id,
                'name' => $this->farmer->name,
            ],
            'transporter' => $this->transporter ? [
                'id' => $this->transporter->id,
                'name' => $this->transporter->name,
            ] : null,
            'quantity' => $this->quantity,
            'unit' => $this->unit,
            'formatted_quantity' => $this->getFormattedQuantity(),
            'total_price' => $this->total_price,
            'currency' => $this->currency,
            'formatted_total_price' => $this->getFormattedTotalPrice(),
            'status' => $this->status,
            'status_display_name' => $this->getStatusDisplayName(),
            'status_color' => $this->getStatusColor(),
            'pickup_location' => $this->pickup_location,
            'delivery_location' => $this->delivery_location,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
} 