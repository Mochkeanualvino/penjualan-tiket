<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class MidtransController
{
    public function create(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'required|string|max:100',
            'gross_amount' => 'required|numeric|min:1',
            'customer_name' => 'required|string|max:100',
            'customer_email' => 'required|email|max:150',
            'customer_phone' => 'nullable|string|max:30',
            'item_name' => 'required|string|max:50',
            'item_qty' => 'required|integer|min:1',
        ]);

        $serverKey = env('MIDTRANS_SERVER_KEY');
        if (!$serverKey) {
            return response()->json([
                'status' => 'error',
                'message' => 'MIDTRANS_SERVER_KEY belum dikonfigurasi di backend.',
            ], 503);
        }

        $baseUrl = filter_var(env('MIDTRANS_IS_PRODUCTION', false), FILTER_VALIDATE_BOOLEAN)
            ? 'https://app.midtrans.com/snap/v1/transactions'
            : 'https://app.sandbox.midtrans.com/snap/v1/transactions';

        $response = Http::withBasicAuth($serverKey, '')
            ->acceptJson()
            ->post($baseUrl, [
                'transaction_details' => [
                    'order_id' => $validated['order_id'],
                    'gross_amount' => (int) $validated['gross_amount'],
                ],
                'customer_details' => [
                    'first_name' => $validated['customer_name'],
                    'email' => $validated['customer_email'],
                    'phone' => $validated['customer_phone'] ?? '',
                ],
                'item_details' => [[
                    'id' => 'ITEM-' . substr(md5($validated['order_id']), 0, 10),
                    'price' => (int) round($validated['gross_amount'] / $validated['item_qty']),
                    'quantity' => $validated['item_qty'],
                    'name' => $validated['item_name'],
                ]],
                'credit_card' => ['secure' => true],
            ]);

        if (!$response->successful()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Midtrans menolak transaksi.',
                'details' => $response->json(),
            ], $response->status() >= 400 && $response->status() < 600 ? $response->status() : 502);
        }

        return response()->json([
            'status' => 'success',
            'data' => $response->json(),
        ]);
    }

    public function status(string $orderId)
    {
        $serverKey = env('MIDTRANS_SERVER_KEY');
        if (!$serverKey) {
            return response()->json([
                'status' => 'error',
                'message' => 'MIDTRANS_SERVER_KEY belum dikonfigurasi di backend.',
            ], 503);
        }

        $baseUrl = filter_var(env('MIDTRANS_IS_PRODUCTION', false), FILTER_VALIDATE_BOOLEAN)
            ? 'https://api.midtrans.com/v2/'
            : 'https://api.sandbox.midtrans.com/v2/';
        $response = Http::withBasicAuth($serverKey, '')
            ->acceptJson()
            ->get($baseUrl . rawurlencode($orderId) . '/status');

        return response()->json([
            'status' => $response->successful() ? 'success' : 'error',
            'data' => $response->json(),
        ], $response->successful() ? 200 : ($response->status() ?: 502));
    }
}
