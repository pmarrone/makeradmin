<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateEmaildispatcherWebhooksTable extends Migration
{
	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::create('emaildispatcher-webhooks', function (Blueprint $table)
		{
			$table->increments('webhook_id');

			$table->enum('event_type', [
				'accepted',
				'rejected',
				'delivered',
				'failed',
				'opened',
				'clicked',
				'unsubscribed',
				'complained',
				'stored',
			]);
			$table->string("mailgun_id");
			$table->decimal("timestamp");
			$table->string("log_level");

			$table->json('event_data');

			$table->dateTimeTz("created_at")->default(DB::raw("CURRENT_TIMESTAMP"));
		});
	}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::drop("emaildispatcher-webhooks");
	}
}