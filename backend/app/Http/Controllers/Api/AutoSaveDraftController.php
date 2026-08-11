<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\AutoSaveDraft;

class AutoSaveDraftController extends Controller
{
    /**
     * Endpoint untuk Simpan Otomatis Input (Auto-Save Realtime)
     */
    public function saveDraft(Request $request)
    {
        $validated = $request->validate([
            'form_key' => 'required|string',
            'draft_data' => 'required|array',
            'timestamp' => 'nullable|string',
        ]);

        $draft = AutoSaveDraft::updateOrCreate(
            ['form_key' => $validated['form_key']],
            [
                'draft_data' => $validated['draft_data'],
                'timestamp' => $validated['timestamp'] ?? now()->toIso8601String(),
            ]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Input draft berhasil disimpan otomatis di backend Laravel API',
            'data' => $draft,
        ]);
    }

    /**
     * Ambil draft input berdasarkan form key
     */
    public function getDraft($formKey)
    {
        $draft = AutoSaveDraft::where('form_key', $formKey)->first();

        if (!$draft) {
            return response()->json([
                'status' => 'not_found',
                'message' => 'Draft tidak ditemukan',
                'data' => null,
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $draft->draft_data,
            'timestamp' => $draft->timestamp,
        ]);
    }

    /**
     * Hapus draft saat form di-submit
     */
    public function clearDraft($formKey)
    {
        AutoSaveDraft::where('form_key', $formKey)->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Draft berhasil dibersihkan',
        ]);
    }
}
