<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jadwals', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('film_id');
            $table->string('studio_id');
            $table->string('tanggal');
            $table->string('jam_tayang');
            $table->decimal('harga', 12, 2);
            $table->timestamps();

            $table->foreign('film_id')->references('id')->on('films')->onDelete('cascade');
            $table->foreign('studio_id')->references('id')->on('studios')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jadwals');
    }
};
