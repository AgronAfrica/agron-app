<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CropResource extends JsonResource
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
            'name' => $this->name,
            'type' => $this->type,
            'quantity' => $this->quantity,
            'unit' => $this->unit,
            'price' => $this->price,
            'currency' => $this->currency,
            'formatted_price' => $this->getFormattedPrice(),
            'formatted_quantity' => $this->getFormattedQuantity(),
            'location' => $this->location,
            'availability_date' => $this->availability_date,
            'description' => $this->description,
            'status' => $this->status,
            'status_display_name' => $this->getStatusDisplayName(),
            'image_url' => $this->getImageUrl(),
            'farmer' => [
                'id' => $this->farmer->id,
                'name' => $this->farmer->name,
                'location' => $this->farmer->location,
            ],
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
} 