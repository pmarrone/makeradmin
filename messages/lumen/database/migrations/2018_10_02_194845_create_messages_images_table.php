<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateMessagesImagesTable extends Migration
{
	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::create("messages_images", function (Blueprint $table)
		{
			$table->increments("image_id");
			$table->string("name_id");

			$table->string("title");
			$table->string("attribution");
			$table->text("description")->nullable();
			$table->string("mime");
			$table->integer('width')->unsigned();
			$table->integer('height')->unsigned();
			$table->longText('data');

			$table->dateTimeTz("created_at")->default(DB::raw("CURRENT_TIMESTAMP"));
			$table->dateTimeTz("updated_at")->nullable();

			$table->unique("name_id");
		});
	}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::drop("messages_images");
	}
}