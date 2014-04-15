define (require, exports, module) ->
	aJazz.App.extend
		className: "viewport"
		template: template require "templates/game.html"
		routes:
			"": "routes/login"
			"index": "routes/index"