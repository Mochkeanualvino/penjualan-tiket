<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Studio;
use Illuminate\Support\Str;

class StudioController extends Controller
{
    public function index()
    {
        return response()->json([
            'status' => 'success',
            'data' => Studio::all(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'kapasitas' => 'required|integer',
            'tipe_studio' => 'required|string|max:100',
        ]);

        $studio = Studio::create([
            'id' => (string) Str::uuid(),
            'nama' => $validated['nama'],
            'kapasitas' => $validated['kapasitas'],
            'tipe_studio' => $validated['tipe_studio'],
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Studio berhasil ditambahkan',
            'data' => $studio,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $studio = Studio::find($id);
        if (!$studio) {
            return response()->json(['status' => 'error', 'message' => 'Studio tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'nama' => 'sometimes|required|string|max:255',
            'kapasitas' => 'sometimes|required|integer',
            'tipe_studio' => 'sometimes|required|string|max:100',
        ]);

        $studio->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Studio berhasil diperbarui',
            'data' => $studio,
        ]);
    }

    public function destroy($id)
    {
        $studio = Studio::find($id);
        if ($studio) {
            $studio->delete();
        }
        return response()->json(['status' => 'success', 'message' => 'Studio berhasil dihapus']);
    }
}
