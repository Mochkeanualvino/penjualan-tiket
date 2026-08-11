<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Jadwal;
use Illuminate\Support\Str;

class JadwalController extends Controller
{
    public function index()
    {
        $jadwal = Jadwal::with(['film', 'studio'])->get();
        return response()->json([
            'status' => 'success',
            'data' => $jadwal,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'film_id' => 'required|string',
            'studio_id' => 'required|string',
            'tanggal' => 'required|string',
            'jam_tayang' => 'required|string',
            'harga' => 'required|numeric',
        ]);

        $jadwal = Jadwal::create([
            'id' => (string) Str::uuid(),
            'film_id' => $validated['film_id'],
            'studio_id' => $validated['studio_id'],
            'tanggal' => $validated['tanggal'],
            'jam_tayang' => $validated['jam_tayang'],
            'harga' => $validated['harga'],
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Jadwal tayang berhasil ditambahkan',
            'data' => $jadwal->load(['film', 'studio']),
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $jadwal = Jadwal::find($id);
        if (!$jadwal) {
            return response()->json(['status' => 'error', 'message' => 'Jadwal tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'film_id' => 'sometimes|required|string',
            'studio_id' => 'sometimes|required|string',
            'tanggal' => 'sometimes|required|string',
            'jam_tayang' => 'sometimes|required|string',
            'harga' => 'sometimes|required|numeric',
        ]);

        $jadwal->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Jadwal berhasil diperbarui',
            'data' => $jadwal->load(['film', 'studio']),
        ]);
    }

    public function destroy($id)
    {
        $jadwal = Jadwal::find($id);
        if ($jadwal) {
            $jadwal->delete();
        }
        return response()->json(['status' => 'success', 'message' => 'Jadwal berhasil dihapus']);
    }
}
