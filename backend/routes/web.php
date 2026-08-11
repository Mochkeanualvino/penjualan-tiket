<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'app' => 'Penjualan Tiket Bioskop API',
        'version' => '1.0.0',
        'status' => 'running',
        'docs' => 'Gunakan prefix /api/v1/ untuk mengakses endpoint API',
    ]);
});
