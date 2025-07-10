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
        Schema::create('crops', function (Blueprint $table) {
            $table->id();
            $table->foreignId('farmer_id')->constrained('users')->onDelete('cascade');
            $table->string('name');
            $table->string('type');
            $table->decimal('quantity', 10, 2);
            $table->string('unit');
            $table->decimal('price', 10, 2);
            $table->string('currency', 3)->default('NGN');
            $table->string('location');
            $table->date('availability_date');
            $table->text('description')->nullable();
            $table->enum('status', ['available', 'sold', 'reserved'])->default('available');
            $table->string('image_path')->nullable();
            $table->timestamps();

            $table->index(['status', 'type']);
            $table->index(['farmer_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('crops');
    }
}; 