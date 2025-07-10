<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DeliveryJobResource extends JsonResource
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
            'job_number' => $this->getJobNumber(),
            'order' => [
                'id' => $this->order->id,
                'order_number' => $this->order->getOrderNumber(),
                'crop' => [
                    'id' => $this->order->crop->id,
                    'name' => $this->order->crop->name,
                    'type' => $this->order->crop->type,
                ],
                'buyer' => [
                    'id' => $this->order->buyer->id,
                    'name' => $this->order->buyer->name,
                ],
                'farmer' => [
                    'id' => $this->order->farmer->id,
                    'name' => $this->order->farmer->name,
                ],
                'quantity' => $this->order->quantity,
                'unit' => $this->order->unit,
                'formatted_quantity' => $this->order->getFormattedQuantity(),
            ],
            'transporter' => $this->transporter ? [
                'id' => $this->transporter->id,
                'name' => $this->transporter->name,
            ] : null,
            'status' => $this->status,
            'status_display_name' => $this->getStatusDisplayName(),
            'status_color' => $this->getStatusColor(),
            'pickup_location' => $this->pickup_location,
            'delivery_location' => $this->delivery_location,
            'estimated_pickup_date' => $this->estimated_pickup_date,
            'estimated_delivery_date' => $this->estimated_delivery_date,
            'actual_pickup_date' => $this->actual_pickup_date,
            'actual_delivery_date' => $this->actual_delivery_date,
            'formatted_estimated_pickup_date' => $this->getFormattedEstimatedPickupDate(),
            'formatted_estimated_delivery_date' => $this->getFormattedEstimatedDeliveryDate(),
            'formatted_actual_pickup_date' => $this->getFormattedActualPickupDate(),
            'formatted_actual_delivery_date' => $this->getFormattedActualDeliveryDate(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
} 