<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;

use DB;

class Webhook extends Controller
{
	/**
	 * Mailgun reference implementation for validating signature
	 * @param string $apiKey
	 * @param string $token
	 * @param int $timestamp
	 * @param string $signature
	 * @return bool
	 */
	private function verify_mailgun_signature($apiKey, $token, $timestamp, $signature): bool{
		//check if the timestamp is fresh
		if (abs(time() - $timestamp) > 15) {
			return false;
		}

		//returns true if signature is valid
		return hash_hmac('sha256', $timestamp.$token, $apiKey) === $signature;
	}

	/**
	 * Send a new message
	 * @param Request $request
	 * @return Response
	 */
	public function callback(Request $request)
	{
		$json = $request->json()->all();

		$signature = $json['signature'];
		$valid = $this->verify_mailgun_signature(config("mailgun.key"), $signature['token'], (int)$signature['timestamp'], $signature['signature']);
		if (!$valid){
			error_log("Received invalid callback: ". json_encode($json));
			return Response()->json([
				"status" => "error",
				"message" => "Forbidden",
			], 403);
		}

		$event_data = $json['event-data'];
		$event_type = $event_data['event'];
		$mailgun_id = $event_data['id'];
		$timestamp = (float)$event_data['timestamp'];
		$log_level = $event_data['log-level'] ?? 'undef';

		DB::table("emaildispatcher-webhooks")->insert([
			'event_type' => $event_type,
			'mailgun_id' => $mailgun_id,
			'timestamp' => $timestamp,
			'log_level' => $log_level,
			'event_data' => $event_data,
		]);

		// Send response to client
		return Response()->json([
			"status" => "ok",
		], 200);
	}
}