<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class OrderRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'crop_id' => 'required|exists:crops,id',
            'quantity' => 'required|numeric|min:0.01',
            'pickup_location' => 'required|string|max:255',
            'delivery_location' => 'nullable|string|max:255',
        ];
    }

    /**
     * Get custom error messages for validation rules.
     */
    public function messages(): array
    {
        return [
            'crop_id.required' => 'Crop selection is required',
            'crop_id.exists' => 'Selected crop does not exist',
            'quantity.required' => 'Quantity is required',
            'quantity.numeric' => 'Quantity must be a number',
            'quantity.min' => 'Quantity must be greater than 0',
            'pickup_location.required' => 'Pickup location is required',
            'pickup_location.max' => 'Pickup location cannot exceed 255 characters',
            'delivery_location.max' => 'Delivery location cannot exceed 255 characters',
        ];
    }
} 