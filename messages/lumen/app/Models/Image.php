<?php
namespace App\Models;

use Makeradmin\Models\Entity;
use DB;

/**
 *
 */
class Image extends Entity
{
	protected $type = "image";
	protected $table = "messages_images";
	protected $id_column = "image_id";
	protected $soft_deletable = false;
	protected $columns = [
		"image_id" => [
			"column" => "messages_images.image_id",
			"select" => "messages_images.image_id",
		],
		"name_id" => [
			"column" => "messages_images.name_id",
			"select" => "messages_images.name_id",
		],
		"title" => [
			"column" => "messages_images.title",
			"select" => "messages_images.title",
		],
		"attribution" => [
			"column" => "messages_images.attribution",
			"select" => "messages_images.attribution",
		],
		"description" => [
			"column" => "messages_images.description",
			"select" => "messages_images.description",
		],
		"mime" => [
			"column" => "messages_images.mime",
			"select" => "messages_images.mime",
		],
		"width" => [
			"column" => "messages_images.width",
			"select" => "messages_images.width",
		],
		"height" => [
			"column" => "messages_images.height",
			"select" => "messages_images.height",
		],
		"imagedata" => [
			"column" => "messages_images.data",
			"select" => "messages_images.data",
		],
		"created_at" => [
			"column" => "messages_images.created_at",
			"select" => "DATE_FORMAT(messages_images.created_at, '%Y-%m-%dT%H:%i:%sZ')",
		],
		"updated_at" => [
			"column" => "messages_images.updated_at",
			"select" => "DATE_FORMAT(messages_images.updated_at, '%Y-%m-%dT%H:%i:%sZ')",
		],
	];
	protected $sort = [
		["created_at", "desc"]
	];
}