<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('crop_id')->constrained()->onDelete('cascade');
            $table->foreignId('buyer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('farmer_id')->constrained('users')->onDelete('cascade');
            $table->decimal('quantity', 10, 2);
            $table->string('unit');
            $table->decimal('total_price', 10, 2);
            $table->string('currency', 3)->default('NGN');
            $table->enum('status', ['pending', 'confirmed', 'in_transit', 'delivered', 'cancelled'])->default('pending');
            $table->string('pickup_location');
            $table->string('delivery_location')->nullable();
            $table->foreignId('transporter_id')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();

            $table->index(['buyer_id', 'status']);
            $table->index(['farmer_id', 'status']);
            $table->index(['transporter_id', 'status']);
            $table->index(['status', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
}; 