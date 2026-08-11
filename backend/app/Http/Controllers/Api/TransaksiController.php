<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Transaksi;
use Illuminate\Support\Str;

class TransaksiController extends Controller
{
    public function index()
    {
        return response()->json([
            'status' => 'success',
            'data' => Transaksi::orderBy('created_at', 'desc')->get(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|string',
            'jadwal_id' => 'required|string',
            'kursi_list' => 'required|array',
            'total_harga' => 'required|numeric',
            'metode_pembayaran' => 'required|string',
        ]);

        $transaksi = Transaksi::create([
            'id' => 'TRX-' . strtoupper(Str::random(8)),
            'user_id' => $validated['user_id'],
            'jadwal_id' => $validated['jadwal_id'],
            'kursi_list' => $validated['kursi_list'],
            'total_harga' => $validated['total_harga'],
            'metode_pembayaran' => $validated['metode_pembayaran'],
            'status' => 'Lunas',
            'tanggal_transaksi' => now()->toDateTimeString(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Transaksi pembelian tiket berhasil diproses',
            'data' => $transaksi,
        ], 201);
    }

    public function updateStatus(Request $request, $id)
    {
        $transaksi = Transaksi::find($id);
        if (!$transaksi) {
            return response()->json(['status' => 'error', 'message' => 'Transaksi tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'status' => 'required|string',
        ]);

        $transaksi->update(['status' => $validated['status']]);

        return response()->json([
            'status' => 'success',
            'message' => 'Status transaksi berhasil diperbarui',
            'data' => $transaksi,
        ]);
    }
}
