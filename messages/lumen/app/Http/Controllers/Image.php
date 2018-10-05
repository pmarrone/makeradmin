<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;

use Makeradmin\Traits\EntityStandardFiltering;

class Image extends Controller
{
	use EntityStandardFiltering;

	const MAX_FILE_SIZE = 250000;

	/**
	 *
	 */
	public function list(Request $request)
	{
		$params = $request->query->all();
		return $this->_list("Image", $params);
	}

	/**
	 *
	 */
	public function create(Request $request)
	{
		$allowed_image_mime = ["image/gif", "image/png", "image/jpeg"];
		//$data = $request->json()->all();
		// Check that the upload was okay
		$file = $request->file("files")[0];
		if ($file->isValid()) {
			if ($file->getSize() > self::MAX_FILE_SIZE) {
				return Response()->json([
					'status' => 'error',
					'message' => 'File too large, (max {self::MAX_FILE_SIZE} bytes allowed)',
				],400);
			}
			$filepath = (string) $file;
			$org_name = $file->getClientOriginalName();
			$mime_type = mime_content_type($filepath);
			if (!$mime_type || !(strncmp($mime_type, "image/", 6) === 0) || !in_array($mime_type, $allowed_image_mime)) {
				throw new \Exception("Unrecognized mime-type {$mime_type} for file: ".$org_name);
			}
			$data = file_get_contents($filepath);
			$image = imagecreatefromstring($data);
			if (!$image) {
				throw new \Exception("Error reading image file: ".$org_name);
			}
			if (imagesx($image) < 1 || imagesy($image) < 1) {
				throw new \Exception("Image size too small: ".$org_name);
			}
			$entity = [
				'name_id' => preg_replace("([^\w\d\-_.])", '', $org_name).time(),
				'title' => '',
				'attribution' => '',
				'mime' => $mime_type,
				'width' => imagesx($image),
				'height' => imagesy($image),
				'imagedata' => base64_encode($data),
			];

			return $this->_create("Image", $entity);
		}
		throw new \Exception("Error uploading file");
	}

	/**
	 *
	 */
	public function read(Request $request, $image_id)
	{
		$params = $request->query->all();
		$params['image_id'] = $image_id;
		return $this->_read("Image", $params);
	}

	/**
	 *
	 */
	public function update(Request $request, $image_id)
	{
		$data = $request->json()->all();
		return $this->_update("Image", [
			"image_id" => $image_id
		], $data);
	}

	/**
	 *
	 */
	public function delete(Request $request, $image_id)
	{
		return $this->_delete("Image", ["image_id" => $image_id], true);
	}
}