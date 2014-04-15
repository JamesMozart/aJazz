define(function(require, exports, module) {
	var Game = require("apps/game"),
		config = aJazz.config;

	//global app config set up
	config.config({
		"dummyRoot": "dummy/",
		"dummyEnabled": true,
		"debug": true
	});

	function boot() {
		var game = new Game({
			viewport: "body"
		});

		game.startHistory();
	}

	boot();
});