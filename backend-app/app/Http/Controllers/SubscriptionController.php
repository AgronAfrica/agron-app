<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class SubscriptionController extends Controller
{
    /**
     * Validate Apple in-app purchase receipt (production first, then sandbox if 21007).
     */
    public function validateReceipt(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'receipt_data' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Invalid request',
                'errors' => $validator->errors(),
            ], 422);
        }

        $receiptData = $request->input('receipt_data');
        $sharedSecret = env('APPLE_SHARED_SECRET'); // Set this in your .env if using auto-renewable subscriptions

        $endpoints = [
            'production' => 'https://buy.itunes.apple.com/verifyReceipt',
            'sandbox' => 'https://sandbox.itunes.apple.com/verifyReceipt',
        ];

        $payload = [
            'receipt-data' => $receiptData,
        ];
        if ($sharedSecret) {
            $payload['password'] = $sharedSecret;
        }

        // Try production first
        $response = $this->postToApple($endpoints['production'], $payload);
        if (!$response['ok']) {
            return response()->json([
                'message' => 'Could not connect to Apple server',
                'error' => $response['error'],
            ], 500);
        }
        $result = $response['body'];

        // If status is 21007, retry with sandbox
        if (isset($result['status']) && $result['status'] == 21007) {
            $response = $this->postToApple($endpoints['sandbox'], $payload);
            if (!$response['ok']) {
                return response()->json([
                    'message' => 'Could not connect to Apple sandbox server',
                    'error' => $response['error'],
                ], 500);
            }
            $result = $response['body'];
        }

        // Log for debugging
        Log::info('Apple receipt validation result', ['result' => $result]);

        return response()->json($result);
    }

    /**
     * Helper to POST to Apple endpoint and return decoded JSON.
     */
    private function postToApple($url, $payload)
    {
        try {
            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
            $result = curl_exec($ch);
            $error = curl_error($ch);
            curl_close($ch);
            if ($result === false) {
                return ['ok' => false, 'error' => $error];
            }
            $body = json_decode($result, true);
            return ['ok' => true, 'body' => $body];
        } catch (\Exception $e) {
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }
} 