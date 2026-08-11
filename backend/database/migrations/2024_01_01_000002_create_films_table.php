<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('films', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('judul');
            $table->string('genre');
            $table->integer('durasi');
            $table->string('rating_usia')->default('SU');
            $table->text('poster_url')->nullable();
            $table->boolean('is_segera_tayang')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('films');
    }
};
