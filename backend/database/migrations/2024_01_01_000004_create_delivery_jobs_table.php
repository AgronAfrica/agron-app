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
            $table->foreignId('transporter_id')->nullable()->constrained('users')->onDelete('set null');
            $table->enum('status', ['open', 'accepted', 'picked_up', 'delivered', 'cancelled'])->default('open');
            $table->string('pickup_location');
            $table->string('delivery_location');
            $table->timestamp('estimated_pickup_date')->nullable();
            $table->timestamp('estimated_delivery_date')->nullable();
            $table->timestamp('actual_pickup_date')->nullable();
            $table->timestamp('actual_delivery_date')->nullable();
            $table->timestamps();

            $table->index(['status', 'created_at']);
            $table->index(['transporter_id', 'status']);
            $table->index(['order_id']);
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