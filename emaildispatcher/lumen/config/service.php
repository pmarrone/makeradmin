<?php

return [
	'name'    => 'Email-dispatcher service',
	'version' => '1.0',
	'url'     => 'emaildispatcher',
	'gateway' => getenv('APIGATEWAY'),
	'bearer'  => getenv('BEARER'),
];