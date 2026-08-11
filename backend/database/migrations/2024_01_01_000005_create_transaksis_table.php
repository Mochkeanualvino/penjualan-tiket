<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaksis', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id');
            $table->string('jadwal_id');
            $table->json('kursi_list');
            $table->decimal('total_harga', 12, 2);
            $table->string('metode_pembayaran');
            $table->string('status')->default('Lunas');
            $table->string('tanggal_transaksi');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transaksis');
    }
};
