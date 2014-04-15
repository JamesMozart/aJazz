###
Login page view class
###
define (require, exports, module)->
	TransView = require "views/TransView"
	MyTabView = require "views/mytab"
	TransView.extend
		className: "page"
		template: template require "templates/login.html"
		events:
			"click|.role-log": (e)->
				alert "this is log"
				return
		render: ->
			TransView::render.call @
			@setView "tab", new MyTabView(), true
			return
		init: (options)->
			loginController = @getController "login"
			loginController.on "success", (e, response)->
				@log = if JSON?
					JSON.stringify response
				else
					response.toString()
				@render$ ".role-log", true
				@bindData "usr", (new Date()).toString()
				return
			, @
			@on "transEnd", (e, visible, forward) ->
				forward && loginController.send usr:(@$ "input").val()
				return
			TransView::init.call @, options
			return