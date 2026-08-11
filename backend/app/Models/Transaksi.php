<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    use HasFactory;

    protected $fillable = [
        'id',
        'user_id',
        'jadwal_id',
        'kursi_list',
        'total_harga',
        'metode_pembayaran',
        'status',
        'tanggal_transaksi',
    ];

    protected $casts = [
        'kursi_list' => 'array',
    ];

    public $incrementing = false;
    protected $keyType = 'string';
}
