define (require, exports, module) ->
	LoginView = require "views/login"
	BaseController = require "controllers/base"

	new aJazz.Route
		enter: (app, query, forward) ->
			view = app.getView "login"
			if !view?
				view = new LoginView
					controllers:
						login: new BaseController()
				app.setView "login", view
			app.bindView "page", view, forward: forward
		level: 0