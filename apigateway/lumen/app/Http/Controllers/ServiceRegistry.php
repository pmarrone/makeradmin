<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\MakerGuard as Auth;

use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

use Makeradmin\Exceptions\EntityValidationException;
use App\Service;
use Makeradmin\Logger;
use Makeradmin\SecurityHelper;
use Makeradmin\Libraries\CurlBrowser;
use Makeradmin\Libraries\CurlMultiPartData;

/**
 * Controller for the service registry
 */
class ServiceRegistry extends Controller
{
	/**
	 * Reqister a new micro service
	 */
	public function register(Request $request)
	{
		$json = $request->json()->all();

		// TODO: Better validation
		if(empty($json["name"]))
		{
			throw new EntityValidationException("name", "required");
		}
		if(empty($json["url"]))
		{
			throw new EntityValidationException("url", "required");
		}
		if(empty($json["endpoint"]))
		{
			throw new EntityValidationException("endpoint", "required");
		}
		if(empty($json["version"]))
		{
			throw new EntityValidationException("version", "required");
		}

		// TODO: Check permissions

		// Check that the service does not already exist
		if(Service::getService($json["url"], $json["version"]))
		{
			return Response()->json([
				"message" => "A service does alredy exist with identical URL and version",
			], 409);
		}

		// Register the service
		Service::register([
			"name"     => $json["name"],
			"url"      => $json["url"],
			"endpoint" => $json["endpoint"],
			"version"  => $json["version"],
		]);

		// Send response
		return Response()->json([
			"message" => "The service was successfully registered",
		], 201);
	}

	/**
	 * Remove an existing micro service
	 */
	public function unregister(Request $request)
	{
		$json = $request->json()->all();

		// TODO: Better validation
		if(empty($json["url"]))
		{
			throw new EntityValidationException("url", "required");
		}
		if(empty($json["version"]))
		{
			throw new EntityValidationException("version", "required");
		}

		// TODO: Check permissions

		// Unregister the service
		Service::unregister([
			"url"     => $json["url"],
			"version" => $json["version"],
		]);

		// Send response
		return Response()->json([
			"message" => "The service was successfully unregistered",
			"data"    => $json,
		], 200);
	}

	/**
	 * Return a list of all registered micro services
	 */
	public function list(Request $request)
	{
		$json = $request->json()->all();

		// Check permissions
		$user = Auth::get()->user();

		// TODO: Send an API request to get the roles and permissions of the user

		// Get a list of all groups where the user have a "api exec" permission
		$groups = [];
		foreach($user->roles as $role)
		{
			foreach($role->permissions as $permission)
			{
				if($permission->permission == "api exec")
				{
					$groups[] = $permission->group_id;
				}
			}
		}
		print_r($groups);
		die("roles\n");

		// List services
		$result = Service::all();

		// Send response to client
		return Response()->json([
			"data"  => $result,
		], 200);
	}

	/**
	 * Handle an incoming HTTP request
	 *
	 * Finds the appropriate micro service and sends a HTTP request to it
	 */
	public function handleRoute(Request $request, $p1, $p2 = null, $p3 = null, $p4 = null, $p5 = null)
	{
		// Split the path into segments and get version + service
		$path = explode("/", $request->path());
		$service = $path[0];
		$version = 1;// TODO: Get version from header

		// Get the endpoint URL or throw an exception if no service was found
		if(($service = Service::getService($service, $version)) === false)
		{
			throw new NotFoundHttpException;
		}

		// Initialize cURL
		$ch = new CurlBrowser;

		// Add a header with authentication information
		$user = Auth::get()->user();
		if ($user) {
			$signed_permissions = SecurityHelper::signPermissionString($user->permissions, $service->signing_token);
			SecurityHelper::addPermissionHeaders($ch, $user->user_id, $signed_permissions);
		} else {
			SecurityHelper::addPermissionHeadersUnauthorized($ch);
		}

		// Forward the authorization header
		$ch->setHeader("Authorization", $request->header("Authorization"));
		$ch->setHeader("Stripe-Signature", $request->header("Stripe-Signature"));

		// Get JSON and POST data
		// TODO: Laravel is probably processing this data and creating a temp file
		$e = explode(";", $request->header("Content-Type"));
		$type = is_array($e) ? $e[0] : $request->header("Content-Type");
		if($type == "application/json")
		{
			$post = $request->json()->all();
			$ch->useJson();
		}
		else if($type == "multipart/form-data")
		{
			$post = new CurlMultiPartData($request->all());
			$ch->setHeader("Content-Type", $type);
		}
		else
		{
			$post = [];
		}

		// Create a new url with the service endpoint url included
		$url = $service->endpoint . implode("/", $path);

		// Send the request
		// Forward the query string parameters like ?sort_by=column etc to the internal request
		$result = $ch->call($request->method(), $url, $request->query->all(), $post);
		$http_code = $ch->getStatusCode();

		// Log the internal HTTP request
		Logger::logServiceTraffic($ch);

		// Send response to client
		return response($result, $http_code)
			->header("Content-Type", "application/json");
	}

	/**
	 * Handles CORS pre-flight requests
	 *
	 * This is an API, so everything should be allowed
	 */
	public function handleOptions(Request $request)
	{
		return response("", 201);
	}

	public function test()
	{
		$user = Auth::get()->user();
		if(!$user)
		{
			return Response()->json([
				"message" => "Hello unauthorized user!",
			], 200);
		}
		else
		{
			return Response()->json([
				"message" => "Hello user {$user->user_id}!",
			], 200);
		}
	}
}