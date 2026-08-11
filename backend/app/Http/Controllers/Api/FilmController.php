<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Film;
use Illuminate\Support\Str;

class FilmController extends Controller
{
    public function index()
    {
        $films = Film::all();
        return response()->json([
            'status' => 'success',
            'data' => $films,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'judul' => 'required|string|max:255',
            'genre' => 'required|string|max:255',
            'durasi' => 'required|integer',
            'rating_usia' => 'required|string|max:10',
            'poster_url' => 'nullable|string',
            'is_segera_tayang' => 'nullable|boolean',
        ]);

        $film = Film::create([
            'id' => (string) Str::uuid(),
            'judul' => $validated['judul'],
            'genre' => $validated['genre'],
            'durasi' => $validated['durasi'],
            'rating_usia' => $validated['rating_usia'],
            'poster_url' => $validated['poster_url'] ?? '',
            'is_segera_tayang' => $validated['is_segera_tayang'] ?? false,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Film berhasil ditambahkan ke database Laravel',
            'data' => $film,
        ], 201);
    }

    public function show($id)
    {
        $film = Film::find($id);
        if (!$film) {
            return response()->json(['status' => 'error', 'message' => 'Film tidak ditemukan'], 404);
        }
        return response()->json(['status' => 'success', 'data' => $film]);
    }

    public function update(Request $request, $id)
    {
        $film = Film::find($id);
        if (!$film) {
            return response()->json(['status' => 'error', 'message' => 'Film tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'genre' => 'sometimes|required|string|max:255',
            'durasi' => 'sometimes|required|integer',
            'rating_usia' => 'sometimes|required|string|max:10',
            'poster_url' => 'nullable|string',
        ]);

        $film->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Film berhasil diperbarui',
            'data' => $film,
        ]);
    }

    public function destroy($id)
    {
        $film = Film::find($id);
        if ($film) {
            $film->delete();
        }
        return response()->json([
            'status' => 'success',
            'message' => 'Film berhasil dihapus',
        ]);
    }
}
