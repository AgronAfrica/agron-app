<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CropRequest extends FormRequest
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
        $rules = [
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:100',
            'quantity' => 'required|numeric|min:0.01',
            'unit' => 'required|string|max:50',
            'price' => 'required|numeric|min:0.01',
            'currency' => 'required|string|max:3',
            'location' => 'required|string|max:255',
            'availability_date' => 'required|date|after_or_equal:today',
            'description' => 'nullable|string|max:1000',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ];

        // For updates, make fields optional
        if ($this->isMethod('PUT') || $this->isMethod('PATCH')) {
            $rules = array_map(function ($rule) {
                return str_replace('required|', '', $rule);
            }, $rules);
        }

        return $rules;
    }

    /**
     * Get custom error messages for validation rules.
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Crop name is required',
            'name.max' => 'Crop name cannot exceed 255 characters',
            'type.required' => 'Crop type is required',
            'type.max' => 'Crop type cannot exceed 100 characters',
            'quantity.required' => 'Quantity is required',
            'quantity.numeric' => 'Quantity must be a number',
            'quantity.min' => 'Quantity must be greater than 0',
            'unit.required' => 'Unit is required',
            'unit.max' => 'Unit cannot exceed 50 characters',
            'price.required' => 'Price is required',
            'price.numeric' => 'Price must be a number',
            'price.min' => 'Price must be greater than 0',
            'currency.required' => 'Currency is required',
            'currency.max' => 'Currency cannot exceed 3 characters',
            'location.required' => 'Location is required',
            'location.max' => 'Location cannot exceed 255 characters',
            'availability_date.required' => 'Availability date is required',
            'availability_date.date' => 'Please enter a valid date',
            'availability_date.after_or_equal' => 'Availability date must be today or in the future',
            'description.max' => 'Description cannot exceed 1000 characters',
            'image.image' => 'File must be an image',
            'image.mimes' => 'Image must be JPEG, PNG, JPG, or GIF',
            'image.max' => 'Image size cannot exceed 2MB',
        ];
    }
} 