define (require, exports, module) ->
	IndexView = require "views/index"

	new aJazz.Route
		enter: (app, query, forward) ->
			view = app.getView "index"
			if !view?
				view = new IndexView()
				app.setView "index", view
			app.bindView "page", view, forward: forward
		level: 1