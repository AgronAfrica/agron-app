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
        Schema::create('delivery_jobs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade');
            $table->foreignId('transporter_id')->constrained('users')->onDelete('cascade');
            $table->string('pickup_location');
            $table->string('delivery_location');
            $table->enum('status', ['pending', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'])->default('pending');
            $table->datetime('pickup_date')->nullable();
            $table->datetime('delivery_date')->nullable();
            $table->string('vehicle_type')->nullable();
            $table->string('vehicle_number')->nullable();
            $table->string('driver_name')->nullable();
            $table->string('driver_phone')->nullable();
            $table->integer('estimated_duration')->nullable(); // in minutes
            $table->integer('actual_duration')->nullable(); // in minutes
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('delivery_jobs');
    }
};
