<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FilmController;
use App\Http\Controllers\Api\StudioController;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\AutoSaveDraftController;

/*
|--------------------------------------------------------------------------
| API Routes - Penjualan Tiket Bioskop (v1)
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // === AUTHENTICATION API ===
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // === AUTO-SAVE INPUT DRAFT API ===
    // Endpoint khusus untuk menyimpan otomatis data input form real-time saat diketik
    Route::post('/drafts/auto-save', [AutoSaveDraftController::class, 'saveDraft']);
    Route::get('/drafts/{formKey}', [AutoSaveDraftController::class, 'getDraft']);
    Route::delete('/drafts/{formKey}', [AutoSaveDraftController::class, 'clearDraft']);

    // === KELOLA FILM API ===
    Route::get('/films', [FilmController::class, 'index']);
    Route::post('/films', [FilmController::class, 'store']);
    Route::get('/films/{id}', [FilmController::class, 'show']);
    Route::put('/films/{id}', [FilmController::class, 'update']);
    Route::delete('/films/{id}', [FilmController::class, 'destroy']);

    // === KELOLA STUDIO API ===
    Route::get('/studios', [StudioController::class, 'index']);
    Route::post('/studios', [StudioController::class, 'store']);
    Route::put('/studios/{id}', [StudioController::class, 'update']);
    Route::delete('/studios/{id}', [StudioController::class, 'destroy']);

    // === KELOLA JADWAL API ===
    Route::get('/jadwal', [JadwalController::class, 'index']);
    Route::post('/jadwal', [JadwalController::class, 'store']);
    Route::put('/jadwal/{id}', [JadwalController::class, 'update']);
    Route::delete('/jadwal/{id}', [JadwalController::class, 'destroy']);

    // === KELOLA TRANSAKSI & PEMESANAN API ===
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);
    Route::put('/transaksi/{id}/status', [TransaksiController::class, 'updateStatus']);
});
