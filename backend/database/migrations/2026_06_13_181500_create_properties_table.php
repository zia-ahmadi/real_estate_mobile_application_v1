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
        Schema::create('properties', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->decimal('price', 12, 2);
            $table->decimal('area', 8, 2);
            $table->unsignedInteger('bedrooms');
            $table->unsignedInteger('bathrooms');
            $table->string('city');
            $table->string('address');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->enum('status', ['available', 'sold'])->default('available');
            $table->boolean('is_featured')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('properties');
    }
};
